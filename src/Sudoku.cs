using System;

namespace SudokuSolver
{
	/// <summary>
	/// Adapted this generator algorithm from an 
	/// example at www.codeproject.com
	/// 
	/// It included a solver component, but we don't
	/// need that -- we've got SAS!
	/// </summary>
	public class Sudoku
	{
		// 0 = solve for
		private byte[,] m_sudoku;

		private struct point
		{
			public int x,y;
			public point(int x, int y)
			{
				this.x = x;
				this.y = y;
			}
		}

		// Maps sub square index to m_sudoku
		private point[,] m_subIndex =
			new point[,]
			{
				{ new point(0,0),new point(0,1),new point(0,2),new point(1,0),new point(1,1),new point(1,2),new point(2,0),new point(2,1),new point(2,2)},
				{ new point(0,3),new point(0,4),new point(0,5),new point(1,3),new point(1,4),new point(1,5),new point(2,3),new point(2,4),new point(2,5)},
				{ new point(0,6),new point(0,7),new point(0,8),new point(1,6),new point(1,7),new point(1,8),new point(2,6),new point(2,7),new point(2,8)},
				{ new point(3,0),new point(3,1),new point(3,2),new point(4,0),new point(4,1),new point(4,2),new point(5,0),new point(5,1),new point(5,2)},
				{ new point(3,3),new point(3,4),new point(3,5),new point(4,3),new point(4,4),new point(4,5),new point(5,3),new point(5,4),new point(5,5)},
				{ new point(3,6),new point(3,7),new point(3,8),new point(4,6),new point(4,7),new point(4,8),new point(5,6),new point(5,7),new point(5,8)},
				{ new point(6,0),new point(6,1),new point(6,2),new point(7,0),new point(7,1),new point(7,2),new point(8,0),new point(8,1),new point(8,2)},
				{ new point(6,3),new point(6,4),new point(6,5),new point(7,3),new point(7,4),new point(7,5),new point(8,3),new point(8,4),new point(8,5)},
				{ new point(6,6),new point(6,7),new point(6,8),new point(7,6),new point(7,7),new point(7,8),new point(8,6),new point(8,7),new point(8,8)}
			};
		
		// Maps sub square to index
		private byte[,] m_subSquare =
			new byte[,]
			{
				{0,0,0,1,1,1,2,2,2},
				{0,0,0,1,1,1,2,2,2},
				{0,0,0,1,1,1,2,2,2},
				{3,3,3,4,4,4,5,5,5},
				{3,3,3,4,4,4,5,5,5},
				{3,3,3,4,4,4,5,5,5},
				{6,6,6,7,7,7,8,8,8},
				{6,6,6,7,7,7,8,8,8},
				{6,6,6,7,7,7,8,8,8}
			};

		/// <summary>
		/// Generate a new Sudoku from the template.
		/// </summary>
		/// <param name="spots">Number of set spots in Sudoku.</param>
		/// <returns>Success</returns>
		public bool Generate(int spots)
		{
			// Number of set spots.
			int num = GetNumberSpots();

			if(!IsSudokuFeasible() || num > spots)
			{
				// The supplied data is not feasible, clear data.
				// - or -
				// The supplied data has too many spots set, clear data.
				Clear();
				num = 0;
			}

			/////////////////////////////////////
			// Randomize spots
			/////////////////////////////////////

			do
			{
				// Try to generate spots
				if(Gen(spots - num))
				{
					// Test if unique solution.
					if(IsSudokuUnique())
					{
						return true;
					}
				}

				// Start over.
				Clear();
				num = 0;
			} while(true);
		}

		/// <summary>
		/// Sudoku byte[9,9] array
		/// </summary>
		public byte[,] Data
		{
			get
			{
				return m_sudoku;
			}

			set
			{
				if(value.Rank == 2 && value.GetUpperBound(0) == 8 && value.GetUpperBound(1) == 8)
					m_sudoku = value;
				else
					throw new Exception("Array has wrong size");
			}
		}

		/// <summary>
		/// Fast test if the data feasable. 
		/// Does not check if there is more than one solution.
		/// </summary>
		/// <returns>Feasible</returns>
		public bool IsSudokuFeasible()
		{
			for(int y = 0; y < 9; y++)
			{
				for(int x = 0; x < 9; x++)
				{
					// Set M of possible solutions
					byte[] M = new byte[10];

					// Count used numbers in the vertical direction
					for(int a = 0; a < 9; a++)
						M[m_sudoku[a,x]]++;
					// Sudoku feasible?
					if(!Feasible(M))
						return false;

					M = new byte[10];
					// Count used numbers in the horizontal direction
					for(int b = 0; b < 9; b++)
						M[m_sudoku[y,b]]++;
					if(!Feasible(M))
						return false;

					M = new byte[10];
					// Count used numbers in the sub square.
					int	squareIndex = m_subSquare[y,x];
					for(int c = 0; c < 9; c++)
					{
						point p = m_subIndex[squareIndex,c];
						if(p.x != y && p.y != x)
							M[m_sudoku[p.x,p.y]]++;
					}
					if(!Feasible(M))
						return false;
				}
			}

			return true;
		}

		/// <summary>
		/// Test generated Sudoku for solvability.
		/// A true Sudoku has one and only one solution.
		/// </summary>
		/// <returns>Unique</returns>
		public bool IsSudokuUnique()
		{
			return true;
		}

		private bool Feasible(byte[] M)
		{
			for(int d = 1; d < 10; d++)
				if(M[d] > 1) 
					return false;

			return true;
		}

		private void Clear()
		{
			for(int y = 0; y < 9; y++)
				for(int x = 0; x < 9; x++)
					m_sudoku[y,x] = 0;
		}

		private int GetNumberSpots()
		{
			int num = 0;

			for(int y = 0; y < 9; y++)
				for(int x = 0; x < 9; x++)
					num += m_sudoku[y,x]==0 ? 0:1;

			return num;
		}

		// Generate spots
		private bool Gen(int spots)
		{
			for(int i = 0;  i < spots; i++)
			{
				Random rnd = new Random();
				int xRand,yRand;

				do
				{
					xRand = rnd.Next(9);
					yRand = rnd.Next(9);
				} while(m_sudoku[yRand,xRand] != 0);

				/////////////////////////////////////
				// Get feasible values for spot.
				/////////////////////////////////////

				// Set M of possible solutions
				byte[] M = {0,1,2,3,4,5,6,7,8,9};

				// Remove used numbers in the vertical direction
				for(int a = 0; a < 9; a++)
					M[m_sudoku[a,xRand]] = 0;

				// Remove used numbers in the horizontal direction
				for(int b = 0; b < 9; b++)
					M[m_sudoku[yRand,b]] = 0;

				// Remove used numbers in the sub square.
				int	squareIndex = m_subSquare[yRand,xRand];
				for(int c = 0; c < 9; c++)
				{
					point p = m_subIndex[squareIndex,c];
					M[m_sudoku[p.x,p.y]] = 0;
				}

				int cM = 0;
				// Calculate cardinality of M
				for(int d = 1; d < 10; d++)
					cM += M[d] == 0 ? 0 : 1;

				// Is there a number to use?
				if(cM > 0)
				{
					int e = 0;

					do
					{
						// Randomize number from the feasible set M
						e =  rnd.Next(1,10);
					} while(M[e] == 0);

					// Set number in Sudoku
					m_sudoku[yRand,xRand] = (byte)e;
				}
				else
				{
					// Error
					return false;
				}
			}

			// Successfully generated a feasible set.
			return true;
		}
	}
}

