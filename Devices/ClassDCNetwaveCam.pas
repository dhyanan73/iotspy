unit ClassDCNetwaveCam;

interface

uses
  ClassDeviceConnect
  , System.Generics.Collections
  , IdComponent;


  type

    TDCNetwaveCam = class (TDeviceConnect, IDeviceConnect)
      procedure OnWorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
      procedure OnWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
      procedure OnWork(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
      procedure OnDisconnected(Sender: TObject);
      procedure OnStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
      const
        DCNC_AUTH_PIVOT_ALIAS = '[[§]]';
        DCNC_AUTH_PIVOT = ':';
      private
        AUsername: string;
        APassword: string;
        AInProgress: boolean;
      protected
        property InProgress: boolean read AInProgress write AInProgress default false;
        function GetAuth: string; override;
        procedure SetAuth(Value: string); override;
      public
        constructor Create; override;
        function Connect(out ErrMsg: string): TDictionary<string, TObject>; override;
    end;

implementation

uses
  System.Types
  , System.StrUtils
  , System.SysUtils
  , IdHTTP
  , System.Classes
  , FMX.Forms
  , FMX.Graphics;

{ TDCNetwaveCam }

function TDCNetwaveCam.Connect(out ErrMsg: string): TDictionary<string, TObject>;
var
  HTTPClient: TIdHTTP;
  URL, OutPut: string;
  Stream: TStringStream;
  StrExtraVal: TStrExtraVal;
  ImgExtraVal: TImgExtraVal;
  BitMap: TBitmap;

begin

  Result := nil;

  try
    URL := StringReplace(Host, 'http://', '', [rfReplaceAll, rfIgnoreCase]);
    URL := 'http://' + URL + ':' + IntToStr(Port) + '/snapshot.cgi';
    HTTPClient := TIdHTTP.Create(nil);
    try
      HTTPClient.ReadTimeout := 120000;
      HTTPClient.AllowCookies := false;
      HTTPClient.Request.ContentLength := -1;
      HTTPClient.Request.ContentRangeEnd := 0;
      HTTPClient.Request.ContentRangeStart := 0;
      HTTPClient.Request.ContentType := 'text/html';
      HTTPClient.Request.Accept := 'text/html, */*';
      HTTPClient.Request.BasicAuthentication := true;
      HTTPClient.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36';
      HTTPClient.Request.Username := AUsername;
      HTTPClient.Request.Password := APassword;
      HTTPClient.Request.Host := Host + ':' + IntToStr(Port);
      HTTPClient.OnWorkBegin := OnWorkBegin;
      HTTPClient.OnWork := OnWork;
      HTTPClient.OnWorkEnd := OnWorkEnd;
      HTTPClient.OnDisconnected := OnDisconnected;
      HTTPClient.OnStatus := OnStatus;
      Stream := TStringStream.Create;
      try
        InProgress := true;
        HTTPClient.Get(URL, Stream);
        while InProgress do
          Application.ProcessMessages;
        if HTTPClient.ResponseCode = 200 then
        begin
          OutPut := Stream.DataString;
          if Trim(OutPut) <> '' then
          begin
            Result := TDictionary<string, TObject>.Create();
            StrExtraVal := TStrExtraVal.Create;
            StrExtraVal.Value := OutPut;
            Result.Add('RawData', StrExtraVal);
            BitMap := TBitmap.Create;
            BitMap.LoadFromStream(Stream);
            ImgExtraVal := TImgExtraVal.Create;
            ImgExtraVal.Value := BitMap;
            Result.Add('Capture', ImgExtraVal);
          end;
        end
        else
          ErrMsg := 'Response code = ' + IntToStr(HTTPClient.ResponseCode);
      finally
        Stream.Free;
      end;
    finally
      HTTPClient.Free;
    end;
  except
    on E: Exception do
    begin
      Result := nil;
      ErrMsg := E.Message;
    end;
  end;

end;

constructor TDCNetwaveCam.Create;
begin

  inherited;

  AUsername := '';
  APassword := '';

end;

function TDCNetwaveCam.GetAuth: string;
begin

  Result := AUsername + DCNC_AUTH_PIVOT + APassword;

end;

procedure TDCNetwaveCam.OnDisconnected(Sender: TObject);
begin

  InProgress := false;

end;

procedure TDCNetwaveCam.OnStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin

  case AStatus of
//    hsResolving, hsConnecting, hsConnected, hsDisconnecting : InProgress := true;
    hsDisconnected, ftpAborted : InProgress := false;
  end;

end;

procedure TDCNetwaveCam.OnWork(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin

  InProgress := true;

end;

procedure TDCNetwaveCam.OnWorkBegin(Sender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin

  InProgress := true;

end;

procedure TDCNetwaveCam.OnWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
begin

  InProgress := false;

end;

procedure TDCNetwaveCam.SetAuth(Value: string);
var
  AuthParts: TStringDynArray;

begin

  inherited;

  if Trim(Value) <> '' then
  begin
    AuthParts := SplitString(Value, DCNC_AUTH_PIVOT);
    if Assigned(AuthParts) and (High(AuthParts) = 1) then
    begin
      AUsername := StringReplace(AuthParts[0], DCNC_AUTH_PIVOT_ALIAS, DCNC_AUTH_PIVOT, [rfReplaceAll]);
      APassword := StringReplace(AuthParts[1], DCNC_AUTH_PIVOT_ALIAS, DCNC_AUTH_PIVOT, [rfReplaceAll]);
    end
    else
      raise Exception.Create('Wrong auth format.');
  end;

end;

end.
