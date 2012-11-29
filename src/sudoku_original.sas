/* copyright (c) SAS Institute 2006   */
/* Purpose:  Solve Sudoku puzzles     */
/* support:  Jim Goodnight            */


data _null_;
array x[9,9]     _temporary_;     /* the puzzle matrix */
array c[9]       _temporary_;     /* values possible for this cell */

array sx[81,9,9] _temporary_;     /* save x matrix before guess */
array sc[81,9]   _temporary_;     /* save c vector after guess  */

array si[81]     _temporary_;     /* save row value of guess */
array sj[81]     _temporary_;     /* save col value of guess */

array cell1[9]   _temporary_ (1 1 1 4 4 4 7 7 7);  /* starting row and col of each square */
array cell2[9]   _temporary_ (3 3 3 6 6 6 9 9 9);  /* ending   row and col of each square */


/*----------------------- Read Data -----------------------------------------*/
read:
do i=1 to 9;
   input x[i,1] x[i,2] x[i,3] x[i,4] x[i,5] x[i,6] x[i,7] x[i,8] x[i,9]; end;

/*----------------------- Count the empty cells and print matrix ------------*/

link blankcnt;
link print;

/*---- Check each cell to see if only 1 number 1-9 can possibly go there ------------*/
/*     Check each row    to see if numbers 1-9 can go in only one cell on the row    */
/*     Check each column to see if numbers 1-9 can go in only one cell on the column */
/*     Check each square to see if numbers 1-9 can go in only one cell in the square */
/*     Do this over and over until no changes were made or there are no blanks left  */

valid=1;
do bl=1 to 81; blanklast=blank;
   link single; link rowcheck; link colcheck; link sqrcheck;
   link blankcnt;
   if ^valid then do;
      Put / "The input matrix is not valid. Be sure it was entered corrrectly."/;
      goto fini; end;
   if blank=0 then goto fini;
   if blank=blanklast then goto guess; /* Every cell can have 2 or more values we need to guess */
   end;

fini: link print;
input a$1;
if a='e' then stop;
put / '--------------------------------------------------' /;
goto read;
return;

/*----------------------- Find If Any Cells can have only 1 value -----------*/

single:

do i1=1 to 9;
   do j1=1 to 9;
      if x[i1,j1]=. then do; link cfill;
         if nmiss=1 then x[i1,j1]=vmiss;
         else if nmiss=0 then valid=0;
         end; end; end;

return;

/*----- see what values are needed on each row and place them if only 1 spot --------*/

rowcheck:

do i1=1 to 9;
   do j=1 to 9; c[j]=0; end;
   do j=1 to 9; v=x[i1,j]; if v then c[v]=1; end;  /* set c[v]=1 if v is in row */

   do v=1 to 9;
      if c[v]=0 then do;
                         /* see if there is only 1 place in row i1 to put a v */
         nloc=0;
         do j1=1 to 9;
            if x[i1,j1]=. then do; found=0;
               do i=1 to 9; if x[i,j1]=v then found=1; end; /* v is in column already */
               if found=0 then do i=cell1[i1] to cell2[i1]; /* square check */
                  do j=cell1[j1] to cell2[j1]; if x[i,j]=v then found=1; end; end;

               if found=0 then do; nloc+1; jloc=j1; end;
               end; end;
         if nloc=1 then x[i1,jloc]=v;
         end; end; end;
return;

/*----- see what values are needed on each col and place them if only 1 spot --------*/

colcheck:

do j1=1 to 9;
   do i=1 to 9; c[i]=0; end;
   do i=1 to 9; v=x[i,j1]; if v then c[v]=1; end;  /* set c[v]=1 if v is in col */

   do v=1 to 9;
      if c[v]=0 then do;
                         /* see if there is only 1 place in col j1 to put a v */
         nloc=0;
         do i1=1 to 9;
            if x[i1,j1]=. then do; found=0;
               do j=1 to 9; if x[i1,j]=v then found=1; end; /* v is in column already */
               if found=0 then do i=cell1[i1] to cell2[i1]; /* check cell */
                  do j=cell1[j1] to cell2[j1]; if x[i,j]=v then found=1; end; end;

               if found=0 then do; nloc+1; iloc=i1; end;
               end; end;
         if nloc=1 then x[iloc,j1]=v;
         end; end; end;
return;

/*----- see what values are needed in each square and place them if only 1 spot --------*/

sqrcheck:

do i1=1,4,7; i2=i1+2;
   do j1=1,4,7; j2=j1+2;

      do i=1 to 9; c[i]=0; end;
      do i=i1 to i2;              /* set c[v]=1 if v is in square */
         do j=j1 to j2; v=x[i,j]; if v then c[v]=1; end; end;

      do v=1 to 9;
         if c[v]=0 then do;
            nloc=0; /* see if there is only 1 place in square to put a v */
            do i=i1 to i2;      /* find the empty cells */
               do j=j1 to j2;
                  if x[i,j]=. then do; found=0;  /* check row and col for a v */
                     do k=1 to 9; if x[k,j]=v or x[i,k]=v then found=1; end;
                     if found=0 then do; nloc+1; iloc=i; jloc=j; end;
                     end; end; end;;
            if nloc=1 then x[iloc,jloc]=v;
            end; end; end; end;
return;




/*----------- Iteratively guess what values go in the empty cells ---------------*/
/*        Always start with the cell with the fewest missing values              */
/*        Once a guess has been made link to the cell,row,col,square search      */
/*        routines to fill in as much of the matrix as possible. If these        */
/*        routines fill it then finished. If it is not filled in completely then */
/*        2 possibilities arise: 1. If an invalid matrix occurs, then restore    */
/*        the matrix and take a second guess. 2. Matrix is still valid so find   */
/*        Another cell with fewest values and guess it's value,   etc.           */

guess: nguess=0; solutions=1;

newguess:nguess+1;
if nguess>81 then goto fini;

do i=1 to 9; do j=1 to 9; sx[nguess,i,j]=x[i,j]; end; end;     /* save x */
nmin=10;
do i1=1 to 9;          /* find the blank cell with the fewest missing values     */
   do j1=1 to 9;
      if x[i1,j1]=. then do; link cfill;
         if nmiss<nmin then do; nmin=nmiss; imin=i1; jmin=j1; end;
         end; end; end;
if nmin=10 then goto fini;           /* cells are full */

solutions=solutions*nmin;       /* solutions is ~ the # of possible solutions */
si[nguess]=imin; sj[nguess]=jmin; i1=imin; j1=jmin; link cfill;
do k=1 to 9; sc[nguess,k]=c[k]; end;                  /* save c vector */

find:           /* setting sc[nguess,k5]=1 prevents k5 from being used again  */
                /* if we ever fall back to this cell                          */
do k5=1 to 9;
   if sc[nguess,k5]=0 then do; x[imin,jmin]=k5; sc[nguess,k5]=1;
      put / "Guess " nguess 2. "  X[" imin 1. "," jmin 1. "] = " k5 1. +2  /;
      link tryit;
      if blank=0 then goto fini;
      if valid then goto newguess;    /* this guess worked and all is well    */
      else do i=1 to 9;               /* try has failed, restore and try next */
         do j=1 to 9; x[i,j]=sx[nguess,i,j]; end; /* restore x */
         end; end; end;

/* all guesses at this level have resulted in invalid data,                */
/* so we need to back up to previous guess cell and try another value there */

if nguess=1 then do; put /"Failed"/; goto fini; end;
nguess=nguess-1;
do i=1 to 9; do j=1 to 9; x[i,j]=sx[nguess,i,j]; end; end; /* restore x */
imin=si[nguess]; jmin=sj[nguess];
goto find;


/*---------------------------Try current guess --------------------------------*/
tryit:
link blankcnt;
link print;

do bl=1 to 81; blanklast=blank;
   link single; link rowcheck; link colcheck; link sqrcheck;
   link blankcnt;
   if blank=0 then return;
   if blank=blanklast then do; /* stuck ... is current state valid */
      valid=1;
      do i1=1 to 9;
         do j1=1 to 9;
            if x[i1,j1]=. then do; link cfill; /* if 1-9 already used nmiss=0 */
               if nmiss=0 then do; valid=0; return; end;
               end; end; end;
      return; end;
   end;
return;


/*------------------------------- Count Blanks --------------------------------*/

blankcnt:blank=0;
do i4=1 to 9; do j4=1 to 9; if x[i4,j4]=. then blank+1; end; end;
return;


/*-------------------------------Fill in c vector -----------------------------*/
/*    For cell x[i1,j1] check what values are already in row i1, col j1, and   */
/*    square containing x[i1,j1].  Set c[k]=1 if k present ,  o otherwise      */

cfill:do k1=1 to 9; c[k1]=0; end;

do k1=1 to 9;
   v=x[i1,k1]; if v then c[v]=1;                        /* check row */
   v=x[k1,j1]; if v then c[v]=1; end;                   /* check col */

do i3=cell1[i1] to cell2[i1];
   do j3=cell1[j1] to cell2[j1];
      v=x[i3,j3]; if v then c[v]=1; end; end;      /* check square */

nmiss=0;                        /* number of values this cell can have */
do k1=1 to 9; if c[k1]=0 then do; vmiss=k1; nmiss+1; end; end;
return;


/*----------------------- Print Routine -------------------------------------*/

print: put /blank=;
put /'-------------------------';
do i4=1 to 9;
   put   '| ' x[i4,1] x[i4,2] x[i4,3] '| ' x[i4,4] x[i4,5] x[i4,6] '| ' x[i4,7] x[i4,8] x[i4,9] '|';
   if (i4=3 | i4=6 | i4=9) then put '-------------------------';
   end;
return;
cards;
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
. . . . . . . . .
-----------------
1 2 3 . . . . . .
4 5 6 . . . . . .
7 8 9 . . . . . .
. . . 1 2 3 . . .
. . . 4 5 6 . . .
. . . 7 8 9 . . .
. . . . . . 1 2 3
. . . . . . 4 5 6
. . . . . . 7 8 9
-----------------
1 2 3 . . . . . .
4 5 6 . . . . . .
7 8 9 . . . . . .
. . . 1 6 7 . . .
. . . 2 5 8 . . .
. . . 3 4 9 . . .
. . . . . . 9 8 3
. . . . . . 4 5 6
. . . . . . 1 2 7
-----------------
1 2 3 . . . . . .
4 5 6 . . . . . .
7 8 9 . . . . . .
. . . 9 8 7 . . .
. . . 4 5 6 . . .
. . . 3 2 1 . . .
. . . . . . 4 5 6
. . . . . . 8 9 1
. . . . . . 7 2 3
-----------------
. 2 7 . . . 6 . .
. 3 . . . . 8 . .
1 . . 5 8 4 . . .
6 . . . . . . 4 .
. . . 2 9 1 . . .
. 7 . . . . . . 5
. . . 8 3 7 . . 9
. . 9 . . . . 7 .
. . 4 . . . 2 1 .
-----------------
. 6 . . . 3 9 . .
5 . . 1 . . . . .
8 . . . . . . . 7
. 4 . 2 . . 6 . .
7 . . . . . . . 8
. . 3 . . 9 . 1 .
2 . . . . . . . 5
. . . . . 4 . . 3
. . 8 7 . . . 2 .
-----------------
. . 4 9 8 . . 7 .
. . 7 . . 5 6 . 3
3 1 . 2 . . . . 9
9 8 . . 1 . 3 . .
. . 1 7 . . . 2 8
6 . . . 2 9 . 4 .
. 4 9 . 5 . . . 6
8 . . 6 . 1 7 . .
. 3 . . . 8 2 9 .
-----------------
. . 7 2 . . . 1 6
6 . 3 . . . . 9 8
. . 2 8 4 . . . 5
. 6 . . . . . 2 .
. . . 9 5 3 . . .
. 1 . . . . . 7 .
2 . . . 7 1 9 . .
4 7 . . . . 6 . 2
8 3 . . . 2 1 . .
-----------------
4 1 . . . . 2 9 .
9 . . 5 3 1 . . .
. 5 7 . . . . . 8
5 . . 1 . . . . .
. . 6 . . . 9 . .
. . . . . 4 . . 7
7 . . . . . 1 3 .
. . . 3 9 2 . . 4
. 8 9 . . . . 6 2
-----------------
. . 5 2 . . . . 1
. . 9 . 8 . . . 4
. . 3 1 . . . . 6
. 2 . . . . . 8 .
. . . 9 6 3 . . .
. 1 . . . . . 7 .
4 . . . . 9 1 . .
8 . . . 7 . 3 . .
6 . . . . 2 5 . .
-----------------
. . 9 . . . 8 . .
. 2 . . . . . 7 .
5 . . 8 . 4 . . 1
. 4 . 9 . 8 . 5 .
3 . 2 . . . 1 . 9
. 6 . 5 . 1 . 4 .
1 . . 6 . 7 . . 2
. 3 . . . . . 6 .
. . 5 . . . 4 . .
e-----------------
;
