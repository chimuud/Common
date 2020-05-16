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
    FRequestText: string;
    procedure SetURL(const Value: string);
  public
    property URL: string read FURL write SetURL;
    property Address: string read FAddress write FAddress;
    property RequestText: string read FRequestText write FRequestText;

    constructor Create(URL: string); overload;
    destructor Destroy; override;

    function Get(endpoint: string; params: TDictionary<string, Variant> = nil): string;
    function Post(endpoint, body: string): Integer;
  end;

implementation

constructor TWCFRest.Create(URL: string);
begin
  idHTTP := TIdHTTP.Create(nil);
  FURL := URL;
end;

destructor TWCFRest.Destroy;
begin
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

function TWCFRest.Get(endpoint: string; params: TDictionary<string, variant> = nil): string;
var
  stream: TStringStream;
  uri: string;
  I: Integer;
  key: string;
  value: Variant;
begin
  uri := URL;
  if endpoint <> '' then
    uri := uri + '/' + endpoint;

  stream := TStringStream.Create;
  try
    if params <> nil then
    begin
      if params.Count > 0 then uri := uri + '?';

      I := 0;
      for key in params.Keys do
      begin
        params.TryGetValue(key, value);
        uri := uri + key + '=' + VarToStr(value);
        if I < params.Count - 1 then
        begin
          uri := uri + '&';
          Inc(I);
        end;
      end;
    end;
    RequestText := uri;
    IdHTTP.Get(uri, stream);
    Result := stream.DataString;
  finally
    stream.Free;
  end;
end;

function TWCFRest.Post(endpoint, body: string): Integer;
var
  RequestBody: TMemoryStream;
  S: string;
  uri: string;
begin
  Result := 0;
{"Age":"52","FirstName":"Jaga","ID":2,"LastName":"Khukhuldei","MiddleName":null}
  uri := URL + '/' + endpoint;
  RequestBody := TMemoryStream.Create;
  try
    body := UTF8Encode(body);
    RequestBody.Write(body[1], Length(body));
//    idHTTP.Request.Accept := 'application/json';
//    idHTTP.Request.ContentType := 'application/json';
    S := idHTTP.Post(uri, RequestBody);
    TryStrToInt(S, Result);
  finally
    RequestBody.Free;
  end;
end;

end.
