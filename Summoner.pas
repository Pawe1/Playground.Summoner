unit Summoner;

interface

uses
  System.Classes,
  System.Rtti,
  Summoner.DebugOptions;

type
  TCustomSummoner = class(TComponent)
  private
    FDebugOptions: TSummonerDebugOptions;

    FClassChecked: Boolean;
    FCreationClassCheck: Boolean;

    FInstance: TObject;

    FRttiContext: TRttiContext;

    FClassName: string;
    FTESTClassName: string;

    procedure CheckClass;   // Dynamic type-checking
    procedure CheckClassName;
    procedure SetCreationClassCheck(const AValue: Boolean);
    procedure SetClassName(const AValue: string);

    function ClassNameAssigned: Boolean;

    function CreateInstance: TObject;
  protected
    property DebugOptions: TSummonerDebugOptions read FDebugOptions write FDebugOptions;

    property CreationClassCheck: Boolean read FCreationClassCheck write SetCreationClassCheck;

    property ClassName: string read FClassName write SetClassName;
    property TESTClassName: string read FTESTClassName write FTESTClassName;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Invoke;

    procedure Test;

    procedure Loaded; override;
  end;

  TSummoner = class(TCustomSummoner)
  published
    property DebugOptions;
    property CreationClassCheck;
    property ClassName;
    property TESTClassName;
  end;

implementation

uses
  System.SysUtils,   // Abort;
  System.Diagnostics,   // TStopwatch
  Winapi.Windows;   // messageboxes

resourcestring
  MsgClassNameEmpty = 'ClassName is empty';
  MsgClassNotFound = 'Class "%s" not found';

type
  ESystemException = Exception;

constructor TCustomSummoner.Create(AOwner: TComponent);
begin
  FDebugOptions := TSummonerDebugOptions.Create;
  inherited;   // in this order because of streaming
end;

destructor TCustomSummoner.Destroy;
begin
  FDebugOptions.Free;
  FRttiContext.Free;
  inherited;
end;

function TCustomSummoner.CreateInstance: TObject;
var
  RttiType: TRttiType;
  InstanceType: TRttiInstanceType;
  ConstructorMethod: TRttiMethod;
  Value: TValue;
begin
  Result := nil;

  RttiType := FRttiContext.FindType(FClassName);
  //Assert(RttiType is TRttiInstanceType);
  InstanceType := RttiType as TRttiInstanceType;

//  if not InstanceType.ClassType.InheritsFrom(TCustomPOSUIWorkplace) then
//    raise ESystemException.CreateFmt('Class %s is not TCustomPOSUIWorkplace class descendant', [InstanceType.Name]);

  ConstructorMethod := InstanceType.GetMethod('Create');
  Value := ConstructorMethod.Invoke(InstanceType.MetaclassType, [Self]);
    //  (V.AsObject as TWinControl).Parent := self;

  Result := Value.AsObject;// as TCustomPOSUIWorkplace;
end;

//procedure TCustomSummoner.BindTask;
//begin
//  with Owner as TCustomPOSUIBasicTask do
//    AttachWorkplace(FInstance);
//end;

//procedure TCustomSummoner.DoInitializing;
//begin
//  if Assigned(FOnInitializing) then
//    try
//      FOnInitializing(FInstance);
//    except
//      if Assigned(ApplicationHandleException) then
//        ApplicationHandleException(Self);
//    end;
//end;

//procedure TCustomSummoner.DoResult;
//begin
//  with Owner as TCustomPOSUIBasicTask do
//  begin
//    Assert(Assigned(FInstance));
//    if Assigned(FOnResult) and (FInstance is TPOSUIBasicWorkplace) then
//      try
//        FOnResult(FInstance,(FInstance as TPOSUIBasicWorkplace).Result);
//      except
//        if Assigned(ApplicationHandleException) then
//          ApplicationHandleException(Self);
//      end;
//  end;
//end;

procedure TCustomSummoner.Invoke;
begin
//  with Owner as TCustomPOSUIBasicTask do
  begin
//    OnWorkplaceExecuted := NAKLADKA;
//    FInstance := CreateInstance;
//    if Assigned(FInstance) then
//    begin
//      BindTask;
//      DoInitializing;
//      FInstance.Initialize;
//    end;

  //  (Workplace as TPOSUIBasicWorkplace).Result

//    OnWorkplaceExecuted := FOnResult;

//    (Owner as TCustomPOSUIBasicTask).

  end;
end;

procedure TCustomSummoner.Loaded;
begin
  writeln(Name + ' lodaed');//messagebox(0, pchar(Name), 'lodaed', 0);
  inherited;
  if FDebugOptions.CheckClassAfterLoaded and ClassNameAssigned then   // gdy kontrola w SetWorkplaceClassName zosta³a pominiêta
    CheckClass;
end;

procedure TCustomSummoner.CheckClassName;
begin
  if FClassName.Trim.IsEmpty then
    raise ESystemException.Create(MsgClassNameEmpty);
end;

procedure TCustomSummoner.CheckClass;
var
  RttiContext: TRttiContext;
begin
  if csDesigning in ComponentState then   // checking this is possible only at runtime
  begin
    MessageBox(0, pchar(name), 'Cannot CheckClass in designtime!', 0);
    Exit;
  end;

  if RttiContext.FindType(FClassName) = nil then
    try
      raise ESystemException.CreateFmt(MsgClassNotFound, [FClassName]);
    except
      if Assigned(ApplicationHandleException) then
        ApplicationHandleException(Self);
    end;

  FClassChecked := True;
end;

procedure TCustomSummoner.SetCreationClassCheck(const AValue: Boolean);
begin
  FCreationClassCheck := AValue;
  if (csLoading in ComponentState) and (not (csDesigning in ComponentState)) and (not FClassName.IsEmpty) then   // ostatni warunek na wszelki wypadek, choæ waroœci chyba wczytuj¹ siê alfabetycznie
end;

procedure TCustomSummoner.SetClassName(const AValue: string);
begin
  FClassName := AValue.Trim;
  FClassChecked := False;
  if not (csLoading in ComponentState) then   // kontrola w przypadku zmian ma sens dopiero po ewentualnym za³adowaniu stanu
    CheckClass;
end;

procedure TCustomSummoner.Test;
const
  test_repeats = 1000;
var
  LC: integer;
  Stopwatch: TStopwatch;
  o: tobject;

 PC: TPersistentClass;

 RttiContext: TRttiContext;
 RttiType: TRttiType;

 InstanceType: TRttiInstanceType;
 ConstructorMethod: TRttiMethod;
 Value: TValue;
begin
  CheckClassName;

  Stopwatch.Reset;
  Stopwatch.Start;
  for LC := 0 to test_repeats do
  begin
    PC := FindClass(FTESTClassName);
    o := PC.Create;
    o.free;
  end;
  Stopwatch.Stop;
  WriteLn(Format('FindClass: %d', [Stopwatch.ElapsedMilliseconds]));//MessageBox(0, pchar(floattostr(Stopwatch.ElapsedMilliseconds)), 'FindClass', 0);

  Stopwatch.Reset;
  Stopwatch.Start;
  for LC := 0 to test_repeats do
  begin
    RttiType := RttiContext.FindType(FClassName);
    //Assert(RttiType is TRttiInstanceType);
    InstanceType := RttiType as TRttiInstanceType;

  //  if not InstanceType.ClassType.InheritsFrom(TCustomPOSUIWorkplace) then
  //    raise ESystemException.CreateFmt('Class %s is not TCustomPOSUIWorkplace class descendant', [InstanceType.Name]);

    ConstructorMethod := InstanceType.GetMethod('Create');
    Value := ConstructorMethod.Invoke(InstanceType.MetaclassType, [self]);
  //  (V.AsObject as TWinControl).Parent := self;

    o := value.AsObject;
    o.free;
  end;
  Stopwatch.Stop;
  WriteLn(Format('RTTI: %d', [Stopwatch.ElapsedMilliseconds]));//MessageBox(0, Pchar(floattostr(Stopwatch.ElapsedMilliseconds)), 'RTTI', 0);
end;

function TCustomSummoner.ClassNameAssigned: Boolean;
begin
  Result := not FClassName.Trim.IsEmpty;
end;

end.
