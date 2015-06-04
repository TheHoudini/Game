program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  dbMgr in 'dbMgr.pas',
  SQLite3 in 'SQLite3.pas',
  SQLiteTable3 in 'SQLiteTable3.pas',
  resultWindow in 'resultWindow.pas' {Form2},
  nameGetter in 'nameGetter.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.                                                                           
