unit uWCFRest;

interface

uses
  Classes, idHTTP, StrUtils, SysUtils, System.Generics.Collections, System.Generics.Defaults,
  Variants;

type
  TWCFRest = class
  private
    FURL: string;
    FAddress: string;

    idHTTP: TIdHTTP;
    FBody: TDictionary<string, Variant>;
    FParams: TDictionary<string, Variant>;
    FHeader: TDictionary<string, Variant>;
    FRequestText: string;
    procedure SetURL(const Value: string);
    function AddOrUpdate(method, endpoint: string): Integer;
    function BodyToJson: string;
  public
    property URL: string read FURL write SetURL;
    property Address: string read FAddress write FAddress;
    property Header: TDictionary<string, Variant> read FHeader write FHeader;
    property Params: TDictionary<string, Variant> read FParams write FParams;
    property Body: TDictionary<string, Variant> read FBody write FBody;
    property RequestText: string read FRequestText write FRequestText;

    constructor Create(URL: string); overload;
    destructor Destroy; override;

    function GetURL(endpoint: string): string;
    function Get(endpoint: string): string;
    function Post(endpoint: string): Integer;
    function Put(endpoint: string): Integer;
    function Delete(endpoint: string): string;
  end;

implementation

uses
  System.JSON;

constructor TWCFRest.Create(URL: string);
begin
  idHTTP := TIdHTTP.Create(nil);
  FParams := TDictionary<string, Variant>.Create;
  FHeader := TDictionary<string, Variant>.Create;
  FBody := TDictionary<string, Variant>.Create;
  FURL := URL;
end;

destructor TWCFRest.Destroy;
begin
  FParams.Free;
  FHeader.Free;
  FBody.Free;
  idHTTP.Free;
  inherited;
end;

{*** Properties ***}

procedure TWCFRest.SetURL(const Value: string);
begin
  FURL := Value;
  if FURL[FURL.Length] <> '/' then
    FURL := FURL + '/';
end;

{*** Properties ***}

function TWCFRest.GetURL(endpoint: string): string;
var
  I: Integer;
  key: string;
  value: Variant;
begin
  Result := URL;
  if endpoint <> '' then
    Result := Result + '/' + endpoint;

  if FParams <> nil then
  begin
    if FParams.Count > 0 then Result := Result + '?';

    I := 0;
    for key in FParams.Keys do
    begin
      FParams.TryGetValue(key, value);
      Result := Result + key + '=' + VarToStr(value);
      if I < FParams.Count - 1 then
      begin
        Result := Result + '&';
        Inc(I);
      end;
    end;
  end;
end;

function TWCFRest.Get(endpoint: string): string;
var
  stream: TStringStream;
begin
  stream := TStringStream.Create;
  try
    IdHTTP.Get(GetURL(endpoint), stream);
    Result := stream.DataString;
  finally
    stream.Free;
  end;
end;

function TWCFRest.Post(endpoint: string): Integer;
begin
  AddOrUpdate('POST', endpoint);
end;

function TWCFRest.Put(endpoint: string): Integer;
begin
  AddOrUpdate('PUT', endpoint);
end;

function TWCFRest.AddOrUpdate(method, endpoint: string): Integer;
var
  RequestBody: TMemoryStream;
  S: string;
  uri: string;
  bodyJson: WideString;
begin
  Result := 0;
  uri := URL + '/' + endpoint;
  RequestBody := TMemoryStream.Create;
  try
    bodyJson := UTF8Encode(BodyToJson());
    RequestBody.Write(bodyJson[1], Length(bodyJson) * SizeOf(Char));
    if method = 'POST' then
      S := idHTTP.Post(uri, RequestBody)
    else
      S := idHTTP.Put(uri, RequestBody);

    TryStrToInt(S, Result);
  finally
    RequestBody.Free;
  end;
end;

function TWCFRest.BodyToJson: string;
var
  Json: TJSONObject;
  key: string;
  value: Variant;
begin
  Json := TJSONObject.Create;
  try
    for key in FBody.Keys do
    begin
      FBody.TryGetValue(key, value);
      Json.AddPair(key, value);
    end;
    Result := Json.ToJSON;
  finally
    Json.Free;
  end;
end;

function TWCFRest.Delete(endpoint: string): string;
var
  stream: TStringStream;
  uri: string;
begin
  stream := TStringStream.Create;
  try
    uri := GetURL(endpoint);
    IdHTTP.Delete(uri, stream);
    Result := stream.DataString;
  finally
    stream.Free;
  end;
end;


end.
