unit ClassDeviceConnect;

interface

uses
  System.Generics.Collections,
  FMX.Graphics;

  type

    TIoTDeviceType = (dtNetwaveCam);

    TImgExtraVal = class
    private
      AValue: TBitmap;
      function GetValue: TBitmap;
      procedure SetValue(Value: TBitmap);
    public
      property Value: TBitmap read GetValue write SetValue default nil;
    end;

    TStrExtraVal = class
    private
      AValue: string;
      function GetValue: string;
      procedure SetValue(Value: string);
    public
      property Value: string read GetValue write SetValue;
      constructor Create;
    end;

    IDeviceConnect = interface
    ['{FECCEE16-20EE-4A5F-A692-9642A6B0498F}']

    {$REGION 'Internal Declarations'}
      function GetHost: string;
      procedure SetHost(Value: string);
      function GetPort: integer;
      procedure SetPort(Value: integer);
      function GetAuth: string;
      procedure SetAuth(Value: string);
    {$ENDREGION 'Internal Declarations'}

      property Host: string read GetHost write SetHost;
      property Port: integer read GetPort write SetPort;
      property Auth: string read GetAuth write SetAuth;
      function Connect(out ErrMasg: string): TDictionary<string, TObject>;
      procedure Free;
    end;

    TDeviceConnect = class (TInterfacedObject, IDeviceConnect)
      private
        AHost: string;
        APort: integer;
        AAuth: string;
        function ExcludeTrailingSlash(const S: string): string;
      protected
        function GetHost: string; virtual;
        procedure SetHost(Value: string); virtual;
        function GetPort: integer; virtual;
        procedure SetPort(Value: integer); virtual;
        function GetAuth: string; virtual;
        procedure SetAuth(Value: string); virtual;
      public
        property Host: string read GetHost write SetHost;
        property Port: integer read GetPort write SetPort default 0;
        property Auth: string read GetAuth write SetAuth;
        constructor Create; virtual;
        destructor Destroy; override;
        function Connect(out ErrMsg: string): TDictionary<string, TObject>; virtual; abstract;
    end;

implementation

uses
  System.SysUtils;

{ TDeviceConnect }

constructor TDeviceConnect.Create;
begin

  inherited Create;

  Host := '';
  Auth := '';

end;

destructor TDeviceConnect.Destroy;
begin

  inherited Destroy;

end;

function TDeviceConnect.GetHost: string;
begin

  Result := AHost;

end;

function TDeviceConnect.GetAuth: string;
begin

  Result := AAuth;

end;

function TDeviceConnect.GetPort: integer;
begin

  Result := APort;

end;

function TDeviceConnect.ExcludeTrailingSlash(const S: string): string;
var
  Index: smallint;

begin

  Result := S;
  Index := High(Result);

  if (Index >= Low(string)) and (Index <= High(Result)) and (Result[Index] = '/')
    and (ByteType(Result, Index) = mbSingleByte) then
    SetLength(Result, Length(Result)-1);

end;

procedure TDeviceConnect.SetHost(Value: string);
begin

  Value := ExcludeTrailingSlash(Value);

  if Value <> AHost then
    AHost := Value;

end;

procedure TDeviceConnect.SetAuth(Value: string);
begin

  if Value <> AAuth then
    AAuth := Value;

end;

procedure TDeviceConnect.SetPort(Value: integer);
begin

  if Value <> APort then
    APort := Value;

end;

{ TImgExtraVal }

function TImgExtraVal.GetValue: TBitmap;
begin

  Result := AValue;

end;

procedure TImgExtraVal.SetValue(Value: TBitmap);
begin

  if (not Assigned(AValue)) or (not AValue.Equals(Value)) then
    AValue := Value;

end;

{ TStrExtraVal }

constructor TStrExtraVal.Create;
begin

  inherited Create;

  SetValue('');

end;

function TStrExtraVal.GetValue: string;
begin

  Result := AValue;

end;

procedure TStrExtraVal.SetValue(Value: string);
begin

  if Value <> AValue then
    AValue := Value;

end;

end.
