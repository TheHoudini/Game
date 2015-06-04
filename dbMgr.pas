unit dbMgr;

interface


uses SQLite3, SQLiteTable3 , sysUtils , resultWindow , nameGetter,windows;



const DB_FILENAME = 'chicken.db'  ;

type
  TDBMgr = class
  public
    constructor Create(var suc:boolean);
    destructor  Destroy;

    procedure processResult(val : integer;var str:string);

  private

    m_db : TSQLiteDatabase;
    m_resWindow : TForm2;
    m_nameGetter : TForm3;

  end;

implementation



{ TDBMgr }

constructor TDBMgr.Create(var suc:boolean);
begin
  suc := true;

  m_db := TSQLiteDatabase.Create(DB_FILENAME);
  m_resWindow := TForm2.Create(nil);
  m_nameGetter := TForm3.Create(nil);


  try
    if( not m_db.TableExists('records') )  then
    begin
      m_db.ExecSQL('CREATE TABLE "records" ( "id"  INTEGER NOT NULL,"name"  TEXT(255) NOT NULL,"value"  INTEGER,PRIMARY KEY ("id"));');
      m_db.ExecSQL('INSERT INTO "main"."records" VALUES (0, "unknown", 0);');
      m_db.ExecSQL('INSERT INTO "main"."records" VALUES (1, "unknown", 0);');
      m_db.ExecSQL('INSERT INTO "main"."records" VALUES (2, "unknown", 0);');
    end;
  except
  suc := false;
  end;

end;

destructor TDBMgr.Destroy;
begin
  m_db.Free;
  m_resWindow.Free;
  m_nameGetter.Free;

end;

procedure TDBMgr.processResult(val : integer;var str : string);
var sltb:TSQLiteTable;
  i:integer;
  name : string;
begin
  sltb := m_db.GetTable('select * from records WHERE value < ' + inttostr(val) + ';' );
  if(sltb = nil ) then
   exit;


  if(sltb.Count > 0 ) then
  begin
    m_nameGetter.ShowModal;


    m_db.ExecSQL('update records set "name"="' + m_nameGetter.Edit1.Text +'",value= ' + inttostr(val) + ' WHERE id='+inttostr(3-sltb.Count)+';' );
  end;


  sltb.Free;

  try
  sltb := m_db.GetTable('SELECT * FROM records;');
  except
    str := 'get table error';
    exit;
  end;

  m_resWindow.memo.Clear;

  for i:=0 to sltb.Count-1 do
  begin
    m_resWindow.memo.Lines.Add(sltb.FieldAsString(0)+ ') ' + sltb.FieldAsString(1)+ ' ' + sltb.FieldAsString(2)          );
    sltb.Next;
  end;



  m_resWindow.Show;

end;

end.
