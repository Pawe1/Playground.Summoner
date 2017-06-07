program Summoning;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Summoner in 'Summoner.pas',
  Test in 'Test.pas' {TestClass: TDataModule},
  Summoner.DebugOptions in 'Summoner.DebugOptions.pas';

var
  Summoner: TSummoner;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    try
      Summoner := TSummoner.Create(nil);

      Summoner.DebugOptions.CheckClassAfterLoaded := True;
      Summoner.ClassName := 'Test.TTestClass';
      Summoner.TESTClassName := 'TTestClass';
      Summoner.Test;
//      Summoner.Invoke;
    finally
      Summoner.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
