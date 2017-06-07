unit Summoner.DebugOptions;

interface

uses
  System.Classes;

type
  TCustomSummonerDebugOptions = class(TPersistent)
  private
   // TypeChecking

    FCheckClassAfterLoaded: Boolean;   // Loaded = works only in case of streaming!
  protected
    property CheckClassAfterLoaded: Boolean read FCheckClassAfterLoaded write FCheckClassAfterLoaded;
  end;

  TSummonerDebugOptions = class(TCustomSummonerDebugOptions)
  published
    property CheckClassAfterLoaded;
  end;

implementation

end.
