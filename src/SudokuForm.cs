// ---------------------------------------------------------------
// Copyright 2007, SAS Institute Inc.
// ---------------------------------------------------------------
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace SudokuSolver
{
	/// <summary>
	/// Windows form for the Sudoku solver task
	/// </summary>
	public class SudokuForm : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Panel panelGrid;
		private System.Windows.Forms.Button btnGenerate;
		private System.Windows.Forms.Button btnSolve;
		private System.Windows.Forms.Button btnCancel;
		private System.Windows.Forms.Label label1;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public SudokuForm()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.panelGrid = new System.Windows.Forms.Panel();
			this.btnGenerate = new System.Windows.Forms.Button();
			this.btnSolve = new System.Windows.Forms.Button();
			this.btnCancel = new System.Windows.Forms.Button();
			this.label1 = new System.Windows.Forms.Label();
			this.SuspendLayout();
			// 
			// panelGrid
			// 
			this.panelGrid.Location = new System.Drawing.Point(20, 56);
			this.panelGrid.Name = "panelGrid";
			this.panelGrid.Size = new System.Drawing.Size(288, 288);
			this.panelGrid.TabIndex = 0;
			// 
			// btnGenerate
			// 
			this.btnGenerate.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnGenerate.Location = new System.Drawing.Point(20, 356);
			this.btnGenerate.Name = "btnGenerate";
			this.btnGenerate.Size = new System.Drawing.Size(108, 23);
			this.btnGenerate.TabIndex = 1;
			this.btnGenerate.Text = "Generate puzzle";
			this.btnGenerate.Click += new System.EventHandler(this.btnGenerate_Click);
			// 
			// btnSolve
			// 
			this.btnSolve.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.btnSolve.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnSolve.Location = new System.Drawing.Point(20, 388);
			this.btnSolve.Name = "btnSolve";
			this.btnSolve.Size = new System.Drawing.Size(108, 23);
			this.btnSolve.TabIndex = 2;
			this.btnSolve.Text = "Solve!";
			this.btnSolve.Click += new System.EventHandler(this.btnSolve_Click);
			// 
			// btnCancel
			// 
			this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnCancel.Location = new System.Drawing.Point(240, 388);
			this.btnCancel.Name = "btnCancel";
			this.btnCancel.TabIndex = 3;
			this.btnCancel.Text = "Cancel";
			// 
			// label1
			// 
			this.label1.Font = new System.Drawing.Font("Trebuchet MS", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
			this.label1.ForeColor = System.Drawing.Color.Purple;
			this.label1.Location = new System.Drawing.Point(20, 4);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(288, 48);
			this.label1.TabIndex = 4;
			this.label1.Text = "Solving your daily Sudoku puzzle so that you can get on with your life.";
			this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
			// 
			// SudokuForm
			// 
			this.AcceptButton = this.btnSolve;
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.CancelButton = this.btnCancel;
			this.ClientSize = new System.Drawing.Size(330, 420);
			this.ControlBox = false;
			this.Controls.Add(this.label1);
			this.Controls.Add(this.btnCancel);
			this.Controls.Add(this.btnSolve);
			this.Controls.Add(this.btnGenerate);
			this.Controls.Add(this.panelGrid);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
			this.MaximizeBox = false;
			this.MaximumSize = new System.Drawing.Size(340, 456);
			this.MinimizeBox = false;
			this.MinimumSize = new System.Drawing.Size(340, 456);
			this.Name = "SudokuForm";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
			this.Text = "Sudoku - the SAS way";
			this.Load += new System.EventHandler(this.SudokuForm_Load);
			this.ResumeLayout(false);

		}
		#endregion

		// array of text boxes used to show/accept puzzle numbers
		TextBox[,] txtNums = new TextBox[9,9];

		// array of colors to create the pattern of the 9x9 grids
		Color[,] colors = new Color[9,9]
			{ 
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue},
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue},
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue},
				{Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite}, 
				{Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite}, 
				{Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite}, 
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue},
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue},
				{Color.LightBlue, Color.LightBlue, Color.LightBlue, Color.AntiqueWhite, Color.AntiqueWhite, Color.AntiqueWhite, Color.LightBlue, Color.LightBlue, Color.LightBlue}
		};

		private void SudokuForm_Load(object sender, System.EventArgs e)
		{
			// upon loading the form, create the text boxes
			// these will be positioned within the placeholder 
			// panel (panelGrid) that is in the form designer.
			for (int row = 0; row <9; row ++)
			{
				for (int col = 0; col <9; col ++	)
				{
					txtNums[row,col] = new TextBox();
					// add to the panel
					panelGrid.Controls.Add(txtNums[row,col]);
					// set location and appearance properties
					txtNums[row,col].Location = new Point(col*32, row*32) ;
					txtNums[row,col].Visible = true;
					txtNums[row,col].Size = new Size(20,20);
					txtNums[row,col].BorderStyle = BorderStyle.FixedSingle;
					txtNums[row,col].TextAlign = HorizontalAlignment.Center;
					txtNums[row,col].BackColor = colors[row,col];
					txtNums[row,col].MaxLength = 1;

					// add an event handler so that we can validate entries
					txtNums[row,col].Validating += new CancelEventHandler(SudokuForm_Validating);
				}
			}

			// fill in the puzzle values, if any
			if (_currentPuzzle!=null && _currentPuzzle.Data!=null)
				PopulateFromData();
		}

		public byte[,] GetData()
		{
			return _currentPuzzle.Data;
		}

		public void SetData(byte[,] newData)
		{
			_currentPuzzle.Data = newData;
		}

		Sudoku _currentPuzzle = new Sudoku();

		// create a new puzzle to solve
		private void btnGenerate_Click(object sender, System.EventArgs e)
		{
			_currentPuzzle = new Sudoku();
			_currentPuzzle.Data = new byte[9,9];
			_currentPuzzle.Generate(20);
			PopulateFromData();
		}

		// read the data structure and fill in the grid
		private void PopulateFromData()
		{
			for (int row = 0; row <9; row ++)
			{
				for (int col = 0; col <9; col ++	)
				{
					if (_currentPuzzle.Data[row, col] !=0)
						txtNums[row, col].Text = _currentPuzzle.Data[row, col].ToString();
					else
						txtNums[row, col].Text = "";
				}
			}

		}

		// validating the value in a text box.  
		// must either be blank or a digit 1-9
		private void SudokuForm_Validating(object sender, CancelEventArgs e)
		{
			if (sender is TextBox)
			{
				if (((TextBox)sender).Text.Trim()!="")
				{
					try
					{
						int i = Convert.ToInt16(((TextBox)sender).Text);
						if (i<1 || i>9)
							throw new System.Exception();
					}
					catch
					{
						MessageBox.Show("Value must be blank or a digit from 1 to 9.");
						e.Cancel = true;
					}
				}
			}
		}

		// On Solve, capture the puzzle data so far and close the form
		// The data will be sent to SAS to solve the puzzle.
		private void btnSolve_Click(object sender, System.EventArgs e)
		{
			byte[,] data = new byte[9,9];
			for (int row = 0; row <9; row ++)
			{
				for (int col = 0; col <9; col ++	)
				{
					byte val;
					if (txtNums[row,col].Text.Trim()=="")
						val=0;
					else
						val = Convert.ToByte(txtNums[row,col].Text);
					data[row,col] = val;
				}
			}
			_currentPuzzle.Data = data;
		}
	}
}
