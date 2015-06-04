unit Unit1;

interface

{.$define AssumeMultiThreaded}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Jpeg ,axCtrls, ComCtrls, Buttons , dbMgr  ;

const
  COMMON_EGG = 'basicEgg';
  DEST_EGG   = 'desttroyerEgg';
  SPEED_EGG  = 'speedEgg';

type                                                                             

  TConvData = record
    count      : integer;
    space      : integer;
    blockSize  : integer;
    speed      : integer;
    timerSize  : integer;
  end;

  TBitMapData = record
    basic      : TBitMap;
    current    : TBitMap;
    chicken    : TBitMap;
    tunnel     : TBitMap;
    theme      : TBitMap;
    wolf       : TBitmap;
    ladder     : TBitmap;
    egg        : TBitMap;
    destEgg    : TBitMap;
    speedEgg   : TBitMap;
  end;

  
  TRenderData = record
    x          :  integer;
    y          :  integer;
    size       :  integer;
    bitmap     : ^TBitMap;
    isRemove   :  boolean;
    isCanTaken :  boolean;
    conv       :  integer;
  end;



  TBmpDataLink  = ^TBitMapData;
  TConvDataLink = ^TConvData;









  TCanvasObject = class
  public
    function getRenderData():TRenderData;virtual;abstract;
    procedure updateObject();virtual;abstract;
    function removeAction():TStringList;virtual;abstract;
  end;



  TWolf = class(TCanvasObject)
  private
    m_renderData   : TRenderData;
    m_convLink     : TConvDataLink;
    m_currentConv  : integer;
    m_currentRow   : integer;

  public
    constructor Create(data : TConvDataLink; bmpData : TbmpDataLink);
    destructor  Destroy;override;

    function    getRenderData():TRenderData;override;
    function    getCurrentConv():integer;
    function    getCurrentRow():integer;
    procedure   updateObject();override;
    procedure   setConv( column : integer;row :integer );

    procedure   moveRight();
    procedure   moveLeft();

    procedure   moveUp() ;
    procedure   moveDown();

  end;


  TBasicEgg = class(TCanvasObject)
  protected
    m_renderData : TRenderData;
    m_convLink   : TConvDataLink;
    m_bmpLink    : TBmpDataLink;
    m_conv       : integer;

    m_removeAction : TStringList;
  public
    constructor Create(data: TConvDataLink; bmpData: TbmpDataLink;conv : integer);
    destructor destroy();



    function    getRenderData():TRenderData;override;
    function    removeAction():TStringList;override;

    procedure   updateObject();override;
    procedure   setData();virtual;
  end;

  TDestroyerEgg = class(TBasicEgg)
  public
    procedure   setData();override;
  end;


  TSpeedEgg = class(TBasicEgg)
  public
    procedure   setData();override;
  end;





  TForm1 = class(TForm)
    RefreshTimer: TTimer;
    log: TMemo;
    lblScore: TLabeledEdit;
    Generator: TTimer;
    btnConvAdd: TBitBtn;
    btnConvRem: TButton;
    btnIncSpeed: TButton;
    Button1: TButton;
    LivesLbl: TLabeledEdit;
    newGameBtn: TButton;
    SpeedIncTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure GeneratorTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnConvAddClick(Sender: TObject);
    procedure btnIncSpeedClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnConvRemClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure newGameBtnClick(Sender: TObject);
    procedure SpeedIncTimerTimer(Sender: TObject);
  private
    { Private declarations }
    // list of eggs
    m_eggList      : TStringList;
    // all bitmaps of app
    m_bmpData      : TBitMapData;
    // conveyer space,blocksize and other
    m_convData     : TConvData;
    // if true, reload static objects
    m_staticReload : boolean;

    // score
    m_score        : integer;
    m_lives        : integer;

    //buck up
    m_key          : integer;

    // this is wolf
    m_wolf         : TWolf;
    // objects being rerender all time
    m_dynamData    : TList ;


    m_dbMgr : TDBMgr;

  public
    { Public declarations }

    // tryed to load  bitmaps from files
    function loadBitMap():boolean;
    // rerender basic bmp if need
    function updateBasicBmp():boolean;
    // tryed to load bitmap data from picture
    function getPictureData(var bmp : TBitMap ; filename : string ):boolean;
    // draw dynamic data
    function drawDynamicData():boolean;

    // update main scene
    function renderScene():boolean;

    // add object to conveyer
    procedure addObject(str : string ) ;
    // do action
    function executeCommand( src : string ):boolean ;

    procedure initEggList();

    // debug
    procedure doLog(str : string);
  end;



var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

function TForm1.loadBitMap: boolean;
begin

  m_bmpData.basic    := TBitMap.Create;

  m_bmpData.current  := TBitMap.Create;
  
  m_bmpData.chicken  := TBitMap.Create;
  m_bmpDatA.chicken.TransparentColor := clAqua;
  m_bmpData.chicken.Transparent := true;

  m_bmpData.tunnel   := TBitMap.Create;
  m_bmpData.tunnel.TransparentColor := clWhite;
  m_bmpData.tunnel.Transparent := true;

  m_bmpData.theme    := TBitMap.Create;

  m_bmpData.ladder := TBItmap.Create;
  m_bmpData.ladder.TransparentColor := clWhite;
  m_bmpData.ladder.Transparent := true;


  m_bmpData.wolf     := TBitMap.Create;
  m_bmpData.wolf.TransparentColor := clWhite;
  m_bmpData.wolf.Transparent := true;


  m_bmpData.egg      := TBitMap.Create;
  m_bmpData.egg.TransparentColor := clWhite;
  m_bmpData.egg.Transparent := true;

  m_bmpData.destEgg  := TBitMap.Create;
  m_bmpData.speedEgg := TBitMap.Create;

  if(not getPictureData(m_bmpData.chicken,'./image/chicken.bmp')) then
  begin
    loadBitMap := false;
    exit;
  end;

  if(not getPictureData(m_bmpData.tunnel,'./image/tunnel.bmp')) then
  begin
    loadBitMap := false;
    exit;
  end;

  if(not getPictureData(m_bmpData.theme,'./image/fon.gif')) then
  begin
    loadBitMap := false;
    exit;
  end;


  if(not getPictureData(m_bmpData.wolf,'./image/wolf.jpg')) then
  begin
    loadBitMap := false;
    exit;
  end;

  if(not getPictureData(m_bmpData.egg,'./image/egg.jpg')) then
  begin
    loadBitMap := false;
    exit;
  end;

  if(not getPictureData(m_bmpData.destEgg,'./image/destEgg.jpg')) then
  begin
    loadBitMap := false;
    exit;

  end;

  if(not getPictureData(m_bmpData.speedEgg,'./image/speedEgg.jpg')) then
  begin
    loadBitMap := false;
    exit;

  end;

  if(not getPictureData(m_bmpData.ladder,'./image/ladder.bmp')) then
  begin
    loadBitMap := false;
    exit;

  end;


  loadBitMap:=true;

end;

procedure TForm1.FormCreate(Sender: TObject);
var suc : boolean;
    deb : string;
begin
  m_dbMgr := TDbMgr.Create(suc);
  if(not suc) then
  dolog('init error');


  randomize;
  if(not loadBitMap() )then
    application.Terminate;

  
  initEggList;
  
  m_convData.count := 4;
  m_convData.speed := 1;
  m_score := 0;
  m_convData.timerSize := refreshTimer.Interval;
  m_staticReload := true;

  m_dynamData := TList.Create;




  m_wolf := TWolf.Create(@m_convData,@m_bmpData);
  m_dynamData.Add(m_wolf);
  m_wolf.setConv(1,2);





  updateBasicBmp();

  addObject('test');


end;

function TForm1.updateBasicBmp: boolean;
var i  :integer;

begin
  if(not m_staticReload ) then
  begin
    updateBasicBmp := true;
    exit;
  end;

  m_bmpData.basic.FreeImage;



  m_bmpData.basic.Height := self.Height;
  m_bmpData.basic.Width  := self.Width;



  m_bmpData.basic.Canvas.StretchDraw(Rect(0,0,self.Width,self.Height),m_bmpData.theme);

  m_convData.blockSize := self.Width div m_convData.count ;
  m_convData.space := (m_convData.blockSize div 3 ) + (m_convData.blockSize mod 3);
  m_convData.blockSize := m_convData.blockSize - m_convData.space;
  m_convData.space :=  (( self.Width - m_convData.blockSize*m_convData.count )  div (m_convData.count-1));

  if( m_convData.blockSize > 300) then
  begin
  m_convData.blockSize := 300;
   m_convData.space :=  (( self.Width - m_convData.blockSize*m_convData.count )  div (m_convData.count-1)) ;
  end;

  m_convData.space := m_convData.space - 5;


  for i:= 0 to m_convData.count-1 do
  begin


    m_bmpData.basic.Canvas.StretchDraw( Rect(i*m_convData.blockSize + i*m_convData.space  , 0
                                       ,i*m_convData.blockSize + i*m_convData.space + m_convData.blockSize, m_convData.blockSize ) , m_bmpData.chicken        );

    m_bmpData.basic.Canvas.StretchDraw( Rect(i*m_convData.blockSize + i*m_convData.space   , m_convData.blockSize
                                       ,i*m_convData.blockSize + i*m_convData.space + m_convData.blockSize  , m_convData.blockSize*2 ) , m_bmpData.tunnel        );

    m_bmpData.basic.Canvas.StretchDraw( Rect(i*m_convData.blockSize + i*m_convData.space   , m_convData.blockSize*2
                                       ,i*m_convData.blockSize + i*m_convData.space + m_convData.blockSize  , m_convData.blockSize*3 ) , m_bmpData.ladder        );
    m_bmpData.basic.Canvas.StretchDraw( Rect(i*m_convData.blockSize + i*m_convData.space   , m_convData.blockSize*3
                                       ,i*m_convData.blockSize + i*m_convData.space + m_convData.blockSize  , m_convData.blockSize*4 ) , m_bmpData.ladder        );

  end;




  updateBasicBmp := true;
end;



function TForm1.getPictureData(var bmp: TBitMap;
  filename: string): boolean;
var
  fs         : TFileStream;
  oleGraphic : TOleGraphic;
begin
  oleGraphic := TOleGraphic.Create;
  try

    fs := TFileStream.Create(filename, fmOpenRead Or fmSharedenyNone);
    oleGraphic.LoadFromStream(fs);
    fs.Free;


    bmp.Width := oleGraphic.Width;
    bmp.Height := oleGraphic.Height;
    bmp.Canvas.Draw(0,0,oleGraphic);


  except
    on e: exception do
    begin
      getPictureData := false;

      oleGraphic.Free;

      exit;
    end;
  end;


  oleGraphic.Free;

  getPictureData := true;

end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  m_staticReload := true;

end;

procedure TForm1.FormResize(Sender: TObject);
begin
   m_staticReload := true;

end;

procedure TForm1.doLog(str: string);
begin
  log.Lines.Add(str);
end;



function TForm1.drawDynamicData: boolean;
var i,j : integer;
    canvObject : TCanvasObject;
    renderData : TRenderData;
    cmdList : TStringList;
    deb :string;
begin

  try
    for i:=0 to m_dynamData.Count-1 do
    begin

     canvObject := m_dynamData[i];
     renderData :=  canvObject.getRenderData;


     if(renderData.isCanTaken) then
     begin
      if(renderData.conv = m_wolf.getCurrentConv)
           AND ((renderData.y div m_convData.blockSize) = m_wolf.getCurrentRow ) then
      begin

       cmdList := canvObject.removeAction;
       for j:= 0 to cmdList.Count -1 do
       begin
        executeCommand(cmdList[j]);
       end;

       canvObject.Free;
       m_dynamData.Remove(canvObject);
       drawDynamicData:=true;
       exit;




      end
      // if wolf not here
      else if(renderData.isRemove) then
        begin
          dec(self.m_lives);
          LivesLbl.Text := inttostr(m_lives) ;
          if(m_lives = 0 ) then
          begin
            Generator.Enabled := false;
            executeCommand('destroy');
            renderScene;
            dolog('loose');

            m_dbMgr.processResult(self.m_score,deb);
            dolog(deb);

          end;

          m_dynamData.Remove(canvObject);
          canvObject.Free;
          drawDynamicData:=true;
          exit;
        end;




     end;

     if(renderData.size < 0 ) then
     begin
      renderData.size := renderData.size * (-1);
      m_bmpData.current.Canvas.StretchDraw( Rect(renderData.x , renderData.y
                                          ,renderData.x + (m_convData.blockSize div renderData.size)
                                          ,renderData.y + (m_convData.blockSize div renderData.size) ), renderData.bitmap^ );

     end else
      m_bmpData.current.Canvas.StretchDraw( Rect(renderData.x , renderData.y
                                          ,renderData.x + (m_convData.blockSize * renderData.size)
                                          ,renderData.y + (m_convData.blockSize * renderData.size) ), renderData.bitmap^ );



     canvObject.updateObject();




    end;

  except
    drawDynamicData := false;
    exit;
  end;

  drawDynamicData := true;


end;

function TForm1.renderScene: boolean;
begin
  if(not updateBasicBmp) then
  begin
    showMessage('cannot update basic bmp');
    renderScene := false;
    exit;
  end;

  m_bmpData.current.FreeImage;
  m_bmpData.current := m_bmpData.basic;

  if(not drawDynamicData) then
  begin
    showMessage('cannot reload dynamic data');
    renderScene := false;
    exit;
  end;

  self.Canvas.StretchDraw(Rect(0,0,self.Width,self.Height),m_bmpData.current );

  renderScene := true;

end;

function TForm1.executeCommand(src: string): boolean;
var cmd,value: string;
    canvObj  : TCanvasObject;
    i , buf  : integer   ;
begin

  i:=1;
  while(  (i <= length(src))  AND (src[i] <> ':')  ) do
  begin
  cmd := cmd + src[i];
  inc(i);
  end;
  inc(i);

  while( i<=length(src) ) do
  begin
  value := value + src[i];
  inc(i);
  end;

  if(length(value) > 0 )then
  begin
    try
     buf := strtoint(value);

      except
      executeCommand:=false;
      exit;
    end;
  end;

  if ( cmd = 'incScore') then
  begin


    m_score := m_score + buf;
    lblScore.Text := 'Score: ' + inttostr(m_score);
    dolog('+'+ inttostr(buf) + ' points');
    executeCommand := true;
    exit;

  end;

  if( cmd = 'destroy') then
  begin
    for i:=m_dynamData.count-1 downto 1 do
    begin
      canvObj := m_dynamData[i];
    //  canvObj.Free;
      m_dynamData.remove(canvObj);
    end;

      m_dynamData.Count := 1;
      executeCommand:=true;
      exit;

      renderScene;

  end;
  if( cmd = 'setSpeed') then
  begin
  m_convData.speed := buf;
  dolog('speed =' + inttostr(m_convData.speed) );
  exit;
  end;

  executeCommand := false;

end;

procedure TForm1.addObject(str: string);
var basicEgg : TBasicEgg;
begin

  if(str = COMMON_EGG )then
  begin
  basicEgg:= TBasicEgg.Create(@m_convData,@m_bmpData,random(m_convData.count)+1);
  m_dynamData.Add(basicEgg);
  end else

  if(str = DEST_EGG ) then
  begin
  basicEgg:= TDestroyerEgg.Create(@m_convData,@m_bmpData,random(m_convData.count)+1);
  m_dynamData.Add(basicEgg);
  end else

  if(str = SPEED_EGG ) then
  begin
  basicEgg:= TSpeedEgg.Create(@m_convData,@m_bmpData,random(m_convData.count)+1);
  m_dynamData.Add(basicEgg);
  end;

end;

procedure TForm1.initEggList;
begin
  m_eggList := TStringList.Create;
  m_eggList.Append(COMMON_EGG);
  m_eggList.Append(DEST_EGG);
  m_eggLIst.Append(SPEED_EGG);
end;



{ TWolf }

constructor TWolf.Create(data: TConvDataLink; bmpData: TbmpDataLink);
begin
  m_convLink := data;
  m_renderData.bitmap := @bmpData^.wolf;
  setConv(1,2);
  m_renderData.size := 1;
end;

destructor TWolf.Destroy;
begin


end;

function TWolf.getCurrentConv: integer;
begin
  getCurrentConv := m_currentConv;
end;

function TWolf.getCurrentRow: integer;
begin
  getCurrentRow := m_currentRow;
end;

function TWolf.getRenderData: TRenderData;
begin
  getRenderData := self.m_renderData;
end;

procedure TWolf.moveDown;
begin
  if(m_currentRow > 2) then
  dec(m_currentRow);

end;

procedure TWolf.moveLeft;
begin
  if(self.m_currentConv > 1)  then
  dec(m_CurrentConv);
end;

procedure TWolf.moveRight;
begin
  if(self.m_currentConv < m_convLink^.count )  then
  inc(m_CurrentConv);
end;

procedure TWolf.moveUp;
begin
  if(m_currentRow < 5) then
    inc(m_currentRow);

end;

procedure TWolf.setConv(column : integer ; row : integer);
begin

  if(column > m_convLink^.count) then
    exit;

  dec(column);

  m_renderData.x := column * m_convLink^.blockSize + column * m_convLink^.space;
  m_renderData.y := m_convLink^.blockSize*row;

  m_currentConv := column + 1;
  m_currentRow := row;

end;

procedure TWolf.updateObject;
begin
  self.setConv(m_currentConv,m_currentRow);
end;

procedure TForm1.RefreshTimerTimer(Sender: TObject);
begin
  renderScene;
end;

{ TBasicEgg }

constructor TBasicEgg.Create(data: TConvDataLink; bmpData: TbmpDataLink;conv : integer );
begin

  m_removeAction := TStringList.Create;

  m_convLink := data;
  m_conv := conv;
  m_bmpLink := bmpData;
  setData();


  m_renderData.size := -4;
  m_renderData.conv := conv;


  dec(m_conv);

  m_renderData.x := (m_convLink^.blockSize * m_conv + m_convLink^.space * m_conv) + (m_convLink^.blockSize div 2)
                            - (m_convLink^.blockSize div ( abs(m_renderData.size )*2 ))    ;

  m_renderData.y := m_convLink^.blockSize;



end;

destructor TBasicEgg.destroy;
begin
  m_removeAction.Free;

end;

function TBasicEgg.getRenderData: TRenderData;
begin
  getRenderdata := m_renderData;
end;

function TBasicEgg.removeAction: TStringList;
begin
  removeAction := m_removeAction;
end;

procedure TBasicEgg.setData;
begin
  m_renderData.bitmap := @m_bmpLink^.egg ;
  m_removeAction.Append('incScore:'+inttostr(100) );
end;

procedure TBasicEgg.updateObject;
begin




  m_renderData.x := (m_convLink^.blockSize * m_conv + m_convLink^.space * m_conv) + (m_convLink^.blockSize div 2)
                            - (m_convLink^.blockSize div ( abs(m_renderData.size ) *2))    ;

  m_renderData.y := m_renderData.y  + m_convLink^.speed;

  if ( m_renderData.y >= (m_convLink^.blockSize*2) ) then
    m_renderData.isCanTaken := true;

  if ( m_renderData.y >= (m_convLink^.blockSize*4) ) then
    m_renderData.isRemove := true;


end;



{ TDestroyerEgg }

procedure TDestroyerEgg.setData;
begin
  m_renderData.bitmap := @m_bmpLink^.destEgg ;
  m_removeAction.Append('destroy');

end;

{ TSpeedEgg }

procedure TSpeedEgg.setData;
begin
  m_renderData.bitmap := @m_bmpLink^.speedEgg ;
  m_removeAction.Append('setSpeed:'+ inttostr(random(4)+1) );

end;

procedure TForm1.GeneratorTimer(Sender: TObject);
begin
  try
  addObject( m_eggList[ {random(m_eggList.Count)} 0] );
  except
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var i:integer;
  ptr : TCanvasObject;
begin

  m_dbMgr.Free;
  
  m_bmpData.basic.Free;   {
  m_bmpData.current.Free; }
  m_bmpData.chicken.Free;
  m_bmpData.tunnel.Free;
  m_bmpData.theme.Free;
  m_bmpData.wolf.Free;
  m_bmpData.egg.Free;
  m_bmpData.destEgg.Free;
  m_bmpData.speedEgg.Free;


  for i:=0 to m_dynamData.Count-1 do
  begin
    ptr := m_dynamData[i];
    ptr.Free;
  end;
  m_dynamData.Free;

  m_eggList.Free;   


end;

procedure TForm1.UpDownChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  //m_convData.count := upDown.v

end;

procedure TForm1.btnConvAddClick(Sender: TObject);
begin
  if(m_convData.count < 9) then
  inc(m_convData.count);
end;

procedure TForm1.btnConvRemClick(Sender: TObject);
begin
  if(m_convData.count > 2 ) then
  dec(m_convData.count);
end;


procedure TForm1.btnIncSpeedClick(Sender: TObject);
begin
  if(m_convData.speed < 5) then
  inc(m_convData.speed);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if(m_convData.speed >1 ) then
  dec(m_convData.speed);
end;


procedure TForm1.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var k : integer;
begin


  if(m_key <> msg.CharCode)then
  begin
    m_key := msg.CharCode;
    exit;
  end;

  m_key := -1;


  case msg.CharCode  of
  39 : m_wolf.moveRight;
  37 : m_wolf.moveLeft;
  40 : m_wolf.moveUp;
  38 : m_wolf.moveDown;
  end;




end;

procedure TForm1.newGameBtnClick(Sender: TObject);
begin
  Generator.Enabled := true;
  self.m_lives := 5;
  self.m_score := 0;
  LivesLbl.Text := inttostr(m_lives);

  m_convData.speed := 1;
  lblScore.Text := inttostr(0);
  log.Clear;


end;

procedure TForm1.SpeedIncTimerTimer(Sender: TObject);
begin
  inc(m_convData.speed);
end;

end.
