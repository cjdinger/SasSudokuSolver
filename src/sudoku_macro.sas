/* Copyright (c) SAS Institute Inc. 2006   */
/* Purpose:  Solve Sudoku puzzles          */
/* Support:  Jim Goodnight                 */ 
%macro sudoku_solver(v11,v12,v13,v14,v15,v16,v17,v18,v19,
                     v21,v22,v23,v24,v25,v26,v27,v28,v29,
                     v31,v32,v33,v34,v35,v36,v37,v38,v39,
                     v41,v42,v43,v44,v45,v46,v47,v48,v49,
                     v51,v52,v53,v54,v55,v56,v57,v58,v59,
                     v61,v62,v63,v64,v65,v66,v67,v68,v69,
                     v71,v72,v73,v74,v75,v76,v77,v78,v79,
                     v81,v82,v83,v84,v85,v86,v87,v88,v89,
                     v91,v92,v93,v94,v95,v96,v97,v98,v99);
                     
data rows(keep=guesses c1-c9);

array x[9,9]     _temporary_;     /* the puzzle matrix */
array c[9]       _temporary_;     /* values possible for this cell */

array sx[81,9,9] _temporary_;     /* save x matrix before guess */
array sc[81,9]   _temporary_;     /* save c vector after guess  */ 

array si[81]     _temporary_;     /* save row value of guess */
array sj[81]     _temporary_;     /* save col value of guess */

array cell1[9] (1 1 1 4 4 4 7 7 7);  /* starting row and col of each square */
array cell2[9] (3 3 3 6 6 6 9 9 9);  /* ending   row and col of each square */
guessnum=0;

   x[1,1]=&v11;
   x[1,2]=&v12;
   x[1,3]=&v13;
   x[1,4]=&v14;
   x[1,5]=&v15;
   x[1,6]=&v16;
   x[1,7]=&v17;
   x[1,8]=&v18;
   x[1,9]=&v19; 

   x[2,1]=&v21;
   x[2,2]=&v22;
   x[2,3]=&v23;
   x[2,4]=&v24;
   x[2,5]=&v25;
   x[2,6]=&v26;
   x[2,7]=&v27;
   x[2,8]=&v28;
   x[2,9]=&v29; 

   x[3,1]=&v31;
   x[3,2]=&v32;
   x[3,3]=&v33;
   x[3,4]=&v34;
   x[3,5]=&v35;
   x[3,6]=&v36;
   x[3,7]=&v37;
   x[3,8]=&v38;
   x[3,9]=&v39; 

   x[4,1]=&v41;
   x[4,2]=&v42;
   x[4,3]=&v43;
   x[4,4]=&v44;
   x[4,5]=&v45;
   x[4,6]=&v46;
   x[4,7]=&v47;
   x[4,8]=&v48;
   x[4,9]=&v49; 

   x[5,1]=&v51;
   x[5,2]=&v52;
   x[5,3]=&v53;
   x[5,4]=&v54;
   x[5,5]=&v55;
   x[5,6]=&v56;
   x[5,7]=&v57;
   x[5,8]=&v58;
   x[5,9]=&v59; 

   x[6,1]=&v61;
   x[6,2]=&v62;
   x[6,3]=&v63;
   x[6,4]=&v64;
   x[6,5]=&v65;
   x[6,6]=&v66;
   x[6,7]=&v67;
   x[6,8]=&v68;
   x[6,9]=&v69; 

   x[7,1]=&v71;
   x[7,2]=&v72;
   x[7,3]=&v73;
   x[7,4]=&v74;
   x[7,5]=&v75;
   x[7,6]=&v76;
   x[7,7]=&v77;
   x[7,8]=&v78;
   x[7,9]=&v79; 

   x[8,1]=&v81;
   x[8,2]=&v82;
   x[8,3]=&v83;
   x[8,4]=&v84;
   x[8,5]=&v85;
   x[8,6]=&v86;
   x[8,7]=&v87;
   x[8,8]=&v88;
   x[8,9]=&v89; 

   x[9,1]=&v91;
   x[9,2]=&v92;
   x[9,3]=&v93;
   x[9,4]=&v94;
   x[9,5]=&v95;
   x[9,6]=&v96;
   x[9,7]=&v97;
   x[9,8]=&v98;
   x[9,9]=&v99; 

/*
 *  Count the empty cells and print matrix
 */

link blankcnt;
link print;

/*  Check each cell to see if only 1 number 1-9 can possibly go there.
 *  Check each row to see if numbers 1-9 can go in only one cell on the row.
 *  Check each column to see if numbers 1-9 can go in only one cell 
 *  on the column.
 *  Check each square to see if numbers 1-9 can go in only one cell 
pp *  in the square 
 *  Do this over and over until no changes were made or there are 
 *  no blanks left  
 */

valid=1;
do bl=1 to 50; blanklast=blank;
   link single; link rowcheck; link colcheck; link sqrcheck;
   link blankcnt;
   if ^valid then do;
    Put / "The input matrix is not valid. Be sure it was entered corrrectly."/;
      goto fini; 
   end;  
   if blank=0 then 
       goto fini;
   if blank=blanklast then 
      goto guess; 
/* 
 *  Every cell can have 2 or more values we need to guess 
 */
end;

fini: link print;
stop;
return;

/*
 * Find If Any Cells can have only 1 value
 */
single:

do i1=1 to 9;
   do j1=1 to 9;
      if x[i1,j1]=. then do; link cfill;
         if nmiss=1 then x[i1,j1]=v;
		 else if nmiss=0 then valid=0; 
         end; end; end;

return;

/*
 * see what values are needed on each row and place them if only 1 spot
 */

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
/*        Another cell with fewest values and guess its value,   etc.           */ 

guess: nguess=0;

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

si[nguess]=imin; sj[nguess]=jmin; i1=imin; j1=jmin; link cfill;
do k=1 to 9; sc[nguess,k]=c[k]; end;                  /* save c vector */

find:           /* setting sc[nguess,k5]=1 prevents k5 from being used again  */
                /* if we ever fall get back to this cell                      */
do k5=1 to 9;
   if sc[nguess,k5]=0 then do; x[imin,jmin]=k5; sc[nguess,k5]=1;
      link tryit;
      if valid then goto newguess;       /* this guess worked and all is well */
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

do bl=1 to 50; blanklast=blank;
   link single; link rowcheck; link colcheck; link sqrcheck;
   link blankcnt; 
   if blank=0 then goto fini;
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
   do k1=1 to 9; if c[k1]=0 then do; v=k1; nmiss+1; end; end;
return;


/*----------------------- Print Routine -------------------------------------*/

print: 

/* place the guess number and records into the output data set */
 guesses = int(guessnum);
 do i4=1 to 9;
   c1=x[i4,1]; c2=x[i4,2]; c3=x[i4,3]; c4=x[i4,4]; c5=x[i4,5]; c6=x[i4,6]; c7=x[i4,7]; c8=x[i4,8]; c9=x[i4,9];
   output;
 end;
 guessnum=guessnum+1;
return;

run;

/* -----------------------------------------------------------------------------*/
/* Now, process the resulting data to see if it's solved, in how many   */
/* tries, and what's the answer                                                        */
/* -----------------------------------------------------------------------------*/

/* count the guesses */
proc sql noprint;
select max(guesses) into :totalguesses
from rows;
quit;

/* create a table of just the answer, or final guess */
proc sql noprint;
create table work.answer as 
select *
from rows
where guesses=&totalguesses;

drop table work.rows;

quit;

data _null_;
	set answer end=eof;
	retain count 0;
	if sum(of c1-c9) = 45 then
		count + 1;
	if (eof = 1) then 
	  call symput("solvable",count=9);
run;


%if &solvable = 1 %then 
	%do;
	title "Solution found in &totalguesses iterations";
	%end;
%else 
	%do; 
	title "Puzzle not solvable after &totalguesses iterations";
	%end;

proc print data=answer noobs label;
label c1="S " c2="U " c3="D " c4="O " c5="K " c6="U " c7="S " c8="A " c9="S ";
var c1-c9;
run;

%mend;

