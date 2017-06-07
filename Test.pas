unit Test;

interface

uses
  System.SysUtils, System.Classes;

type
  TTestClass = class(TDataModule)
  private
    { Private declarations }
  public
    destructor Destroy; override;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure ForceReferenceToClass(C: TClass);
begin
  // instead of $STRONGLINKTYPES ON directiwe because it causes generation of bigger EXE file
end;

destructor TTestClass.Destroy;
begin
//  WriteLn('destructor TTestClass.destroy');
  inherited;
end;

initialization
  ForceReferenceToClass(TTestClass);

  RegisterClass(TTestClass);

end.
