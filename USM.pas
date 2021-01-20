unit USM;

interface

uses  System.SysUtils, System.Classes, System.Json, Datasnap.DSServer, Datasnap.DSAuth, Datasnap.DSHTTPWebBroker,
      Web.HTTPApp;

type
{$METHODINFO ON}
  TSM = class(TComponent)
  private
    { Private declarations }
    function primary_key(const tabela : string)       : integer;
  public
    { Public declarations }
    function Cliente(const ID_Cliente: integer = 0)   : TJSONObject; // GET
    function UpdateCliente                            : TJSONObject; // POST
    function AcceptCliente(const ID_Cliente: integer) : TJSONObject; // PUT
    function CancelCliente(const ID_Cliente: integer) : TJSONObject; // DELETE
  end;
{$METHODINFO OFF}

implementation


uses System.StrUtils, FPrincipal;

// PUT
function TSM.AcceptCliente(const ID_Cliente: integer): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Message', 'PUT');
end;

// DELETE
function TSM.CancelCliente(const ID_Cliente: integer): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Message', 'DELETE');
end;

// GET
function TSM.Cliente(const ID_Cliente: integer): TJSONObject;
const
  _SELECT = 'SELECT * FROM clientes ';
begin
  with FormPrincipal do
  begin
    DB_Query.Active := false;
    DB_Query.SQL.Text := _SELECT;

    Result := TJSONObject.Create;
    if ID_Cliente > 0 then
    begin
      DB_Query.SQL.Add(' WHERE codigo = :ID_Cliente ');
      DB_Query.ParamByName('ID_Cliente').Value := ID_Cliente;
      DB_Query.Open;

      Result.AddPair('codigo', DB_Query.FieldByName('codigo').Value);
      Result.AddPair('nome', DB_Query.FieldByName('nome').Value);
      Result.AddPair('cpf', DB_Query.FieldByName('cpf').Value);
      Result.AddPair('endereco', DB_Query.FieldByName('endereco').Value);
      Result.AddPair('setor', DB_Query.FieldByName('setor').Value);
      Result.AddPair('cidade', DB_Query.FieldByName('cidade').Value);
      Result.AddPair('uf', DB_Query.FieldByName('uf').Value);
      Result.AddPair('cep', DB_Query.FieldByName('cep').Value);
      Result.AddPair('Telefone 1', DB_Query.FieldByName('fone').Value);
      Result.AddPair('Telefone 2', DB_Query.FieldByName('fone_1').Value);
      Result.AddPair('email 1', DB_Query.FieldByName('e_mail').Value);
      Result.AddPair('email 2', DB_Query.FieldByName('e_mail1').Value);
    end
    else Result.AddPair('Message', 'Por favor insira um ID');

  end;
end;

// Pegar a chave prim�ria da tabela dada
function TSM.primary_key(const tabela: string): integer;
begin
  with FormPrincipal do
  begin
    DB_IDGen.Active := false;
    DB_IDGen.SQL.Text := 'SELECT FIRST 1 * FROM '+tabela+' ORDER BY codigo DESC';
    DB_IDGen.Open;

    Result := DB_IDGen.FieldByName('codigo').AsInteger;
    DB_IDGen.Close;
  end;
end;

// POST
function TSM.UpdateCliente: TJSONObject;
const
  _INSERT = 'INSERT INTO clientes (codigo, nome, cpf, endereco, setor, cidade, cep, uf, fone, fone_1, e_mail, e_mail1)';
var
  WebModule   : TWebModule;
  Requisicao  : TJSONArray;
  Valores     : TJSONValue;
  clienteObj  : TJSONObject;
begin
  Result := TJSONObject.Create;
  Try
    WebModule := GetDataSnapWebModule;
  Except on E : Exception do
    Result.AddPair('Message', 'Erro ao recueprar conte�do');
  End;

  if WebModule.Request.Content.IsEmpty then
  begin
      Result.AddPair('Message', 'Conte�do vazio');
  end;

    Requisicao := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(WebModule.Request.Content), 0)
      as TJSONArray;

  for Valores in Requisicao do
    begin
      // Constroi o objeto JSON do Cliente
      clienteObj := TJSONObject.Create;
      clienteObj.AddPair('NomeCliente', Valores.GetValue<string>('nomedocliente'));
      clienteObj.AddPair('CPF', Valores.GetValue<string>('cpf'));
      clienteObj.AddPair('Endereco', Valores.GetValue<string>('endereco'));
      clienteObj.AddPair('bairro', Valores.GetValue<string>('bairro'));
      clienteObj.AddPair('cidade', Valores.GetValue<string>('cidade'));
      clienteObj.AddPair('cep', Valores.GetValue<string>('cep'));
      clienteObj.AddPair('uf', Valores.GetValue<string>('uf'));
      clienteObj.AddPair('telefone1', Valores.GetValue<string>('telefone1'));
      clienteObj.AddPair('telefone2', Valores.GetValue<string>('telefone2'));
      clienteObj.AddPair('email1', Valores.GetValue<string>('email1'));
      clienteObj.AddPair('email2', Valores.GetValue<string>('email2'));

      with FormPrincipal do
      begin
        DB_Query.Active := false;
        DB_Query.SQL.Text := _INSERT;
        DB_Query.SQL.Add(' VALUES (:codigo, :nome, :cpf, :endereco, :bairro, :cidade, :cep, :uf, :telefone1, :telefone2, :email1, :email2)');

        DB_Query.ParamByName('codigo').Value := primary_key('clientes')+1;
        DB_Query.ParamByName('nome').Value := clienteObj.Values['NomeCliente'].Value;
        DB_Query.ParamByName('cpf').Value := clienteObj.Values['CPF'].Value;
        DB_Query.ParamByName('endereco').Value := clienteObj.Values['Endereco'].Value;
        DB_Query.ParamByName('bairro').Value := clienteObj.Values['bairro'].Value;
        DB_Query.ParamByName('cidade').Value := clienteObj.Values['cidade'].Value;
        DB_Query.ParamByName('cep').Value := clienteObj.Values['cep'].Value;
        DB_Query.ParamByName('uf').Value := clienteObj.Values['uf'].Value;
        DB_Query.ParamByName('telefone1').Value := clienteObj.Values['telefone1'].Value;
        DB_Query.ParamByName('telefone2').Value := clienteObj.Values['telefone2'].Value;
        DB_Query.ParamByName('email1').Value := clienteObj.Values['email1'].Value;
        DB_Query.ParamByName('email2').Value := clienteObj.Values['email2'].Value;


        Try
          DB_Query.ExecSQL;
        Except on E : Exception do
          Result.AddPair('Exception', E.Message);
        End;

      end;

      Result.AddPair('Cliente', clienteObj);
    end;
end;

end.

