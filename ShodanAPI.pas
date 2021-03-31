unit ShodanAPI;

interface

  const
    SHODAN_API_ENDPOINT = 'https://api.shodan.io/shodan/host';

  type

    TShoShodan = class
    private
      Acrawler: string;
      Aptr: boolean;
      Aid: string;
      Amodule: string;
    public
      property crawler: string read Acrawler write Acrawler;
      property ptr: boolean read Aptr write Aptr default false;
      property id: string read Aid write Aid;
      property module: string read Amodule write Amodule;
      constructor Create;
    end;

    TShoHTTP = class
    private
      Arobots_hash: string;
      Aredirects: TArray<string>;
      Asecuritytxt: string;
      Atitle: string;
      Asitemap_hash: string;
      Arobots: string;
      Aserver: string;
      Ahost: string;
      Ahtml: string;
      Alocation: string;
      Asecuritytxt_hash: string;
      Asitemap: string;
      Ahtml_hash: Int64;
    public
      property robots_hash: string read Arobots_hash write Arobots_hash;
      property redirects: TArray<string> read Aredirects write Aredirects;
      property securitytxt: string read Asecuritytxt write Asecuritytxt;
      property title: string read Atitle write Atitle;
      property sitemap_hash: string read Asitemap_hash write Asitemap_hash;
      property robots: string read Arobots write Arobots;
      property server: string read Aserver write Aserver;
      property host: string read Ahost write Ahost;
      property html: string read Ahtml write Ahtml;
      property location: string read Alocation write Alocation;
      property securitytxt_hash: string read Asecuritytxt_hash write Asecuritytxt_hash;
      property sitemap: string read Asitemap write Asitemap;
      property html_hash: Int64 read Ahtml_hash write Ahtml_hash default 0;
      constructor Create;
    end;

    TShoLocation = class
    private
      Acity: string;
      Aregion_code: string;
      Aarea_code: string;
      Alongitude: double;
      Acountry_code3: string;
      Alatitude: double;
      Apostal_code: string;
      Adma_code: integer;
      Acountry_code: string;
      Acountry_name: string;
    public
      property city: string read Acity write Acity;
      property region_code: string read Aregion_code write Aregion_code;
      property area_code: string read Aarea_code write Aarea_code;
      property longitude: double read Alongitude write Alongitude;
      property country_code3: string read Acountry_code3 write Acountry_code3;
      property latitude: double read Alatitude write Alatitude;
      property postal_code: string read Apostal_code write Apostal_code;
      property dma_code: integer read Adma_code write Adma_code default 0;
      property country_code: string read Acountry_code write Acountry_code;
      property country_name: string read Acountry_name write Acountry_name;
      constructor Create;
    end;

    TShoMatch = class
    private
      Aproduct: string;
      Ahash: Int64;
      Aip: Int64;
      Aorg: string;
      Aisp: string;
      Atransport: string;
      Acpe: TArray<string>;
      Adata: string;
      Aasn: string;
      Aport: word;
      Ahostnames: TArray<string>;
      Alocation: TShoLocation;
      Atimestamp: string;
      Adomains: TArray<string>;
      Ahttp: TShoHTTP;
      Aos: string;
      A_shodan: TShoShodan;
      Aip_str: string;
    public
      property product: string read Aproduct write Aproduct;
      property hash: Int64 read Ahash write Ahash default 0;
      property ip: Int64 read Aip write Aip default 0;
      property org: string read Aorg write Aorg;
      property isp: string read Aisp write Aisp;
      property transport: string read Atransport write Atransport;
      property cpe: TArray<string> read Acpe write Acpe;
      property data: string read Adata write Adata;
      property asn: string read Aasn write Aasn;
      property port: word read Aport write Aport default 0;
      property hostnames: TArray<string> read Ahostnames write Ahostnames;
      property location: TShoLocation read Alocation write Alocation;
      property timestamp: string read Atimestamp write Atimestamp;
      property domains: TArray<string> read Adomains write Adomains;
      property http: TShoHTTP read Ahttp write Ahttp;
      property os: string read Aos write Aos;
      property _shodan: TShoShodan read A_shodan write A_shodan;
      property ip_str: string read Aip_str write Aip_str;
      constructor Create;
    end;

    TShoResponse = class
    private
      Amatches: TArray<TShoMatch>;
      Atotal: Int64;
      Aerror: string;
    public
      property matches: TArray<TShoMatch> read Amatches write Amatches;
      property total: Int64 read Atotal write Atotal default 0;
      property error: string read Aerror write Aerror;
      constructor Create;
      destructor Destroy; override;
      procedure ConcatMatches(Matches: TArray<TShoMatch>);
    end;

    function GetQueryResults(ApiKey: string; Query: string; out ErrMsg: string; MaxCount: Int64 = 0; Retries: word = 5): TShoResponse;

implementation

uses
// [START] DELPHI NEON
  Neon.Core.Persistence
  , Neon.Core.Types
  , Neon.Core.Persistence.JSON
  , System.TypInfo
// [END] DELPHI NEON
  , System.Generics.Collections
  , REST.Client
  , REST.Types
  , System.JSON
  , System.SysUtils
  , FMX.Forms

// [START] DEBUG
  , System.Classes;

function GetUUID(Clean: boolean = false): string;
var
  GUID: TGUID;

begin

  Result := '';

  if CreateGUID(GUID) = 0 then
     Result := GUIDToString(GUID);

  if Clean then
  begin
    Result := StringReplace(Result, '{', '', [rfReplaceAll]);
    Result := StringReplace(Result, '}', '', [rfReplaceAll]);
    Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  end;

end;

procedure StrToFile(const FileName, SourceString: string);
var
  List: TStringList;

begin

  List := TStringList.Create;

  try
    List.Text := SourceString;
    List.SaveToFile(FileName);
  finally
    List.Free;
  end;

end;

// [END] DEBUG

function APIRequest(Resource: string; out ErrMsg: string; Params: TDictionary<string, string>; ApiKey: string; Page: Int64 = 1): TJSONObject;
var
  JSON: TJSONObject;
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  Key, Content: string;

begin

  Result := nil;
  ErrMsg := '';

  try
    RESTClient := TRESTClient.Create(SHODAN_API_ENDPOINT);
    try
      RESTClient.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
      RESTClient.AcceptCharset := 'UTF-8, *;q=0.8';
      RESTClient.ContentType := 'application/json; charset=utf-8';
      RESTClient.HandleRedirects := false;
      RESTClient.SecureProtocols := [];
      RESTRequest := TRESTRequest.Create(nil);
      try
        RESTRequest.Client := RESTClient;
        RESTRequest.Timeout := 180000;
        RESTRequest.Resource := Resource;
        RESTRequest.Method := TRESTRequestMethod.rmGET;
        RESTRequest.Params.Clear;
        RESTRequest.Params.AddItem('key', ApiKey, TRESTRequestParameterKind.pkGETorPOST);
        RESTRequest.Params.AddItem('page', IntToStr(Page), TRESTRequestParameterKind.pkGETorPOST);
        RESTRequest.Params.AddItem('minify', 'true', TRESTRequestParameterKind.pkGETorPOST);
        if Assigned(Params) then
        begin
          for Key in Params.Keys do
            RESTRequest.Params.AddItem(Key, Params[Key], TRESTRequestParameterKind.pkGETorPOST);
        end;
        RESTResponse := TRESTResponse.Create(nil);
        try
          RESTRequest.Response := RESTResponse;
          RESTRequest.Execute;
          Content := RESTResponse.Content;

//          StrToFile(GetUUID(true) + '.json', Content);  // debug

          JSON := TJSONObject.Create;
          if JSON.Parse(BytesOf(Content), 0) > 0 then
            Result := JSON;
        finally
          RESTResponse.Free;
        end;
      finally
        RESTRequest.Free;
      end;
    finally
      RESTClient.Free;
    end;
  except
    on E: Exception do
    begin
      Result := nil;
      ErrMsg := E.Message;
    end;
  end;

end;

function GetQueryResults(ApiKey: string; Query: string; out ErrMsg: string; MaxCount: Int64 = 0; Retries: word = 5): TShoResponse;
var
  QueryResult: TJSONObject;
  Params: TDictionary<string, string>;
  LConfig: INeonConfiguration;
  LReader: TNeonDeserializerJSON;
  MaxPages: Int64;
  Response: TShoResponse;
  Page: Int64;
  Retry: word;

begin

  Result := nil;

  try
    Params := TDictionary<string, string>.Create;
    try
      Params.Add('query', Query);
      MaxPages := 0;
      if MaxCount > 0 then
      begin
        MaxPages := Trunc(MaxCount / 100);
        if (MaxCount - (MaxPages * 100)) <> 0 then
          MaxPages := MaxPages + 1;
      end;
      LConfig :=  TNeonConfiguration.Default
                  .SetMemberCase(TNeonCase.SnakeCase)
                  .SetMembers([TNeonMembers.Properties])
                  .SetIgnoreFieldPrefix(false)
                  .SetVisibility([mvPublic]);
      LReader := TNeonDeserializerJSON.Create(LConfig);
      try
        Retry := 0;
        repeat
          Application.ProcessMessages;
          QueryResult := APIRequest('search', ErrMsg, Params, ApiKey);
          Application.ProcessMessages;
          if not Assigned(QueryResult) then
          begin
            Retry := Retry + 1;
            Application.ProcessMessages;
            Sleep(1000);
            Application.ProcessMessages;
          end;
        until Assigned(QueryResult) or (Retry > Retries);
        if Assigned(QueryResult) then
        begin
          try
            Result := TShoResponse.Create;
            LReader.JSONToObject(Result, QueryResult);
            if Assigned(Result) then
            begin
              Page := 2;
              Retry := 0;
              while (Assigned(QueryResult) or (Retry <= Retries)) and ((MaxPages = 0) or (Page <= MaxPages)) do
              begin
                Application.ProcessMessages;
                QueryResult := APIRequest('search', ErrMsg, Params, ApiKey, Page);
                Application.ProcessMessages;
                if Assigned(QueryResult) then
                begin
                    Retry := 0;
                    Response := TShoResponse.Create;
                    LReader.JSONToObject(Response, QueryResult);
                    if Assigned(Response) then
                    begin
                      try
                        if Response.error = '' then
                        begin
                          if Length(Response.matches) = 0 then
                            Exit;
                          Result.ConcatMatches(Response.matches);
                        end
                        else
                        begin
                          Result := nil;
                          ErrMsg := Response.error;
                          Exit;
                        end;
                      finally
                        Response.Free;
                      end;
                    end;
                end
                else
                begin
                  if ErrMsg <> '' then
                  begin
                    Retry := Retry + 1;
                    if Retry <= Retries then
                    begin
                      Application.ProcessMessages;
                      Sleep(1000);
                      Application.ProcessMessages;
                      Continue;
                    end
                    else
                    begin
                      FreeAndNil(Result);
                      ErrMsg := ErrMsg + ' (#' + IntToStr(Page) + ')';
                    end;
                  end;
                end;
                Page := Page + 1;
              end;
            end;
          finally
            if Assigned(QueryResult) then
              QueryResult.Free;
          end;
        end;
      finally
        LReader.Free;
      end;
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FreeAndNil(Result);
      ErrMsg := E.Message;
    end;
  end;

end;


{ TShoLocation }

constructor TShoLocation.Create;
begin

  inherited Create;

  city := '';
  region_code := '';
  area_code := '';
  country_code3 := '';
  postal_code := '';
  country_code := '';
  country_name := '';
  longitude := 0;
  latitude := 0;

end;

{ TShoHTTP }

constructor TShoHTTP.Create;
begin

  inherited Create;

  robots_hash := '';
  redirects := nil;
  securitytxt := '';
  title := '';
  sitemap_hash := '';
  robots := '';
  server := '';
  host := '';
  html := '';
  location := '';
  securitytxt_hash := '';
  sitemap := '';

end;

{ TShoShodan }

constructor TShoShodan.Create;
begin

  inherited Create;

  crawler := '';
  id := '';
  module := '';

end;

{ TShoMatch }

constructor TShoMatch.Create;
begin

  inherited Create;

  product := '';
  org := '';
  isp := '';
  transport := '';
  cpe := nil;
  data := '';
  asn := '';
  hostnames := nil;
  location := TShoLocation.Create;
  timestamp := '';
  domains := nil;
  http := TShoHTTP.Create;
  os := '';
  _shodan := TShoShodan.Create;
  ip_str := '';

end;

{ TShoResponse }

procedure TShoResponse.ConcatMatches(Matches: TArray<TShoMatch>);
var
  CurrLen, i: Int64;

begin

  CurrLen := Length(Amatches);
  SetLength(Amatches, CurrLen + Length(Matches));
  for i := Low(Matches) to High(Matches) do
    Amatches[CurrLen + i] := Matches[i];

end;

constructor TShoResponse.Create;
begin

  inherited Create;

  matches := nil;
  error := '';

end;

destructor TShoResponse.Destroy;
begin

  inherited;
  Amatches := nil;

end;

end.
