# SAS custom task example: Sudoku Solver
***
This repository contains one of a series of examples that accompany
_Custom Tasks for SAS Enterprise Guide using Microsoft .NET_ 
by [Chris Hemedinger](http://support.sas.com/hemedinger).

This is a "bonus" example that didn't make it into the book,
but it's one of the earliest custom tasks that I released
([going back to 2007](http://blogs.sas.com/content/sascom/2007/04/11/puzzling-presentations/)).  
It was built using C# 
with Microsoft Visual Studio 2003.  It should run in SAS Enterprise Guide 4.1 and later.

## About this example
This project contains the source for a custom task, usable in 
SAS Enterprise Guide 4.1 and SAS Add-In for Office 2.1.

Here is the layout of files in the project:
- AssemblyInfo.cs - assembly attributes with description, copyright info, etc.
- CustomTask.ico - the icon that appears for this task in the menu and 
process flow.
- Global.cs - a C# class that contains some utility functions.
- Sudoku.cs - a C# class that can generate sudoku puzzles.
- sudoku_original.sas - the original SAS program to solve the sudoku puzzle.
This file is included only for reference; it's not used within
the project.
- sudoku_macro.sas - a revised version of the SAS program, wrapped in a macro.
- SudokuForm.cs - a C# class for the Windows Form -- the user interface for this task
- SudokuSolver.cs - a C# class that implements the custom task APIs, derived from the
interfaces published in SAS.Shared.AddIns.dll.
- bin/SudokuSolver.dll - the custom task DLL that you can install and use, as is.

