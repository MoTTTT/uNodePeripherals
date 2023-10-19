  Buff1: array [1..3855] of byte;
  Buff2: array [1..3855] of byte;
  FPGAReLoad: Boolean;
  FPGAReset : Boolean;
  PCh1 : Pchar;
  ReadBuf : array[1..5] of byte;
  Filler1: word;
  WritenByte: byte;
  Filler2: Word;
  buf: pchar;
  ReadSize  : smallint;
  FailCnt: smallint;
  ReadByte: byte;
  InitFPGA: SmallInt;
  Response: Boolean;
  NoActTest : Byte;
  POPSTOP : BOOLEAN;
  discmd3 : boolean;
  discmd3c : boolean;
  NoInBytes: byte;
  WaitNoResponse: Boolean;
  TEMPNORESP: INTEGER;


const Ok : Byte = 0;
      Timeout: Byte = 1;
      CheckSumErr: Byte = 2;
      NotTXing: Byte = 3;
      StatusByte: Byte = 3;
      RepError: Byte = 5;
      CheckStatus : Byte = 6;
      ResetFPGACmd: Byte = 7;

implementation
{$R *.DFM}



function TMain.GetStatus(Id: Byte): Byte;
label GetStatusStart;
begin

  if WaitForTx(200) = Timeout then
     begin
       NoTxDialogue(Id);
     end;

GetStatusStart:

   If WriteCommand(Id,CheckStatus) = Timeout then
     begin
       If NoTxDialogue(Id) = true then
         begin
           goto GetStatusStart ;
         end
       else
         begin
           GetStatus := Timeout;
         end;
      end
    else
      begin
         Error := ReadFrame(4);
         if Error = CheckSumErr then
            begin
              if CheckSumDialogue(Id) = false then
                 begin
                   GetStatus := CheckSumErr;
                 end
              else
                 begin
                    goto GetStatusStart;
                 end;
            end
         else if Error = TimeOut then
            begin
              if NoResponseDialogue(Id) = false then
                 begin
                   GetStatus := TimeOut;
                 end
               else
                 begin
                    goto GetStatusStart;
                 end;
            end
          else
            begin
               GetStatus := Ok;
            end;
      end;
end;

Function TMain.NoResponseDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' is not responding.  Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoResponseDialogue := true;
                end;
end;
Function TMain.CheckSumDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' returned a corrupt frame. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    CheckSumDialogue := true;
                end;
end;
Function TMain.NoTxDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' Output Queue is not empty. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoTxDialogue := true;
                end;
end;
Function TMain.NoResetDialogue(Id: Byte; FPGAnum: byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + 'FPGA ' + inttostr(FPGANum) +
              ' has not reset successfully. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoResetDialogue := true;
                end;
end;

Function TMain.NoProgramDialogue(Id: Byte; FPGAnum: byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' has not programmed successfully.'+
              ' Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoProgramDialogue := true;
                end;
end;

Function TMain.ResetFPGA(Id: Byte) : Byte;
label ResetStart;
begin

ResetStart:

   If WriteCommand(Id,ResetFPGACmd) = Timeout then
     begin
       If NoTxDialogue(Id) = true then
         begin
           goto ResetStart;
         end
       else
          begin
            ResetFPGA := TimeOut;
          end;
      end
    else
      begin
         ResetFPGA := Ok;
      end;
end;

Function TMain.WriteByte(WritenByte: Byte) :byte;
begin
    Pch1:= @WritenByte;
    TransmitCommChar(hComm, Pch1^);
end;

Function TMain.WriteCommand(Id: Byte; Cmd: Byte) : Byte;
var TxResponse : Boolean;
begin
 WritenByte := Id;
 WriteByte(WritenByte);
 WritenByte := Cmd;    {Command}
 WriteByte(WritenByte);
 CheckSum := id + Cmd ;
 WritenByte := CheckSum;      {CheckSum}
 WriteByte(WritenByte);

 WriteCommand := WaitForTx(1000);

end;

Function TMain.WriteFPGAFile(Id: Byte; FPGANum: Byte) : Byte;
var TxResponse : Boolean;
begin
 WriteByte(Id);
 WriteByte(FPGANum);

 if FPGANum = 1 then
   begin
     WriteComm(hComm, @Buff1, 3854);
   end
 else
    begin
     WriteComm(hComm, @Buff2, 3854);
   end;

 WriteFPGAFile := WaitForTx(4000);

end;


function TMain.WaitForTX(TimeOutValue: Integer): Byte;
label StartLoopTx, EndProcTx;
begin

WaitNoResponse:= false;

StartLoopTx:

GetCommError(hComm,Stat);

if stat.cbOutQue = 0 then
   begin
      WaitForTx := Ok;
      goto EndProcTx;
   end;

If LoopCount > TimeOutValue then
    begin
      WaitForTx := timeout;
      goto EndProcTx;
    end;

for looptime := 1 to 400 do
    begin
      waittime := waittime + 1;
    end;

LoopCount := LoopCount + 1;

goto StartLoopTx;

EndProcTx:

end;


function TMain.ReadFrame(Length: Byte): Byte;
var CheckSum: Byte;
label StartLoopRx, EndProcRx, ReadRx;
begin

WaitNoResponse:= false;

StartLoopRx:

GetCommError(hComm,Stat);

if stat.cbInQue = Length then goto ReadRx;

If LoopCount > 200 then
    begin
      ReadFrame := TimeOut;
      goto EndProcRx;
    end;

for looptime := 1 to 100 do
    begin
      waittime := waittime + 1;
    end;

LoopCount := LoopCount + 1;

goto StartLoopRx;

ReadRx:

CheckSum := 0;
for LoopCount := 1 to Length do
  begin
    buf := @readbuf[LoopCount];
    ReadComm(hComm,Buf,ReadSize);
    CheckSum := CheckSum + ReadBuf[LoopCount];
  end;

   CheckSum := ReadBuf[LoopCount];

If CheckSum <> ReadBuf[LoopCount] then
  begin
    ReadFrame := CheckSumErr;
  end;

EndProcRx:

end;

procedure TMain.InitialiseTester(Sender: TObject);
label Reset,FPGALOAD1,FPGALOAD2;
begin

if GetStatus(TestId) = TimeOut then Exit;
Reset:
If WriteCommand(TestId,ResetFPGACmd) = TimeOut then
   begin
     if NoTxDialogue(TestId) = False then
       begin
         exit;
       end
     else
       begin
         goto Reset;
       end;
    end;

If GetStatus(TestId) = timeout then exit;

if (ReadBuf[StatusByte] and BinMask[4]) <> 0 then
  begin
      if NoResetDialogue(TestId,1) = false then
        begin
          Exit;
        end
     else
        begin
           goto Reset;
        end;
   end;

if (ReadBuf[StatusByte] and BinMask[5]) <> 0 then
   begin
     if NoResetDialogue(TestId,2) = false then
        begin
          Exit;
        end
     else
        begin
           goto Reset;
        end;
    end;
FPGALOAD1:

 if WriteFPGAFile(TestId,1) = TimeOut then
    begin
       If NoTxDialogue(TestId) = true then
         begin
           goto FPGALOAD1;
         end
       else
         begin
           exit;
         end;
     end;

FPGALOAD2:

    if WriteFPGAFile(TestId,2) = TimeOut then
     begin
       If NoTxDialogue(TestId) = true then
         begin
           goto FPGALOAD2;
         end
       else
         begin
           exit;
         end;
     end;

if GetStatus(TestId) = TimeOut then Exit;

if (ReadBuf[StatusByte] and BinMask[6]) <> 0 then
   begin
     if NoProgramDialogue(TestId,1) = false then
        begin
          Exit;
        end
     else
        begin
           goto FPGALOAD1;
        end;
    end;

if (ReadBuf[StatusByte] and BinMask[7]) <> 0 then
    begin
     if NoProgramDialogue(TestId,2) = false then
        begin
          Exit;
        end
     else
        begin
           goto FPGALOAD2;
        end;
     end;
end;

procedure TMain.FormCreate(Sender: TObject);
type F1 = Byte;
var F: file;
    f2: file;
    filename : string;
    LoopCount: Integer;
    RBPch :PChar;
    RBuf: Char;
begin
      ReadSize := 1;
      main.top := 6;
      main.left := 6;
      BinMask[0] := 1;
      BinMask[1] := 2;
      BinMask[2] := 4;
      BinMask[3] := 8;
      BinMask[4] := 16;
      BinMask[5] := 32;
      BinMask[6] := 64;
      BinMask[7] := 128;
      Initialised[1]:= false;
      Initialised[2]:= false;
      Initialised[3]:= false;
      Initialised[4]:= false;
      Initialised[5]:= false;
      Initialised[6]:= false;
      Response := false;
      FPGAReLoad := false;
      Popstop := false;
      discmd3 := false;
      discmd3c := false;
{Load Configfiles for testers in array}

{FILE 1 - FPGA 1}
      filename := 'Test1.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F, 1);
      while not Eof(F) do
         begin
           BlockRead(F,Buff1[LoopCount],1927);
           Loopcount := loopcount + 1927;
         end;
      CloseFile(F);
      CfgLength1 := LoopCount - 1;


{FILE 2 - FPGA 2}

     filename := 'Test2.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F,1);
      while not Eof(F) do
         begin
           BlockRead(F,Buff2[LoopCount],1927);
           Loopcount := loopcount + 1927;
         end;
    CloseFile(F);
    CfgLength2 := LoopCount - 1;
end;

procedure TMain.Timer1Timer(Sender: TObject);
begin
if TimerCycle = 1 then
      begin
      TimerCycle := 0;
      for loopcount := 1 to 6 do
         begin
          TestId := loopcount;
             if ActiveTester[TestId] = true then
                begin
                  InterfChange(Sender);     {Done}
                  CheckInsError(Sender);    {Done}
                  CheckDtrChange(Sender);   {Martin}
                  TestPatternSet(Sender);      {Done}
                  ExecCmd3Sync(Sender);     {Done}
                  ExecCmd30Status(Sender);  {Done}
                  ElapsTime(Sender);        {Done}
                end;
         end;
      end
  else
     TimerCycle := 1;
      for loopcount := 1 to 6 do
         begin
          TestId := loopcount;
             if ActiveTester[TestId] = true then
                begin
                  ReportErrors(Sender);     {Done}
                end;
         end;
end;

procedure TMain.ComClear(Sender: TObject);
begin
   CloseComm(hComm);
end;

procedure TMain.ComSetup(Sender: TObject);
var Def: string;
    pc : PChar;
    FlPc: Pchar;
    FlagSets: word;
begin
  ReadBufferSize:= 10;
  WriteBufferSize:= 3900;
  hComm:=OpenComm(CommStr,ReadBufferSize,WriteBufferSize);
  EscapeCommFunction(hComm, 1);
  Def := Commstr1 + ',19200,8,0,1,,,,' + ;
  pc := @Def;
  if BuildCommDCB(@Def,DCB) <> 0 then
    begin
      Showmessage('DCB Build Failed');
      exit;
    end;  }
  DCB.Flags := 49408;
  DCB.Parity:= 0;
  DCB.BaudRate:=19200;
  DCB.ByteSize:=8;
  DCB.StopBits:= 0;
  DCB.Id:=hcomm;
  SetCommState(DCB);
  if GetCommState(hComm,DCB) <> 0 then
   begin
    showMessage('-Setting Failed -' +
               (' baudrate :' + inttostr(DCB.Baudrate) +
               (' byteReadSize : 8'  + '  parity : None' +
               (' hcomm :' + inttostr(DCB.id)))));
    EscapeCommFunction(hComm, 1);
    GetCommState(hComm,DCB);
    MessageDlg(' Check the Hardware and Check that no other Applications' +
    ' is using the selected Port', mtInformation, [mbOk], 0);
    exit;
    end;
GetCommState(hComm,DCB);
   begin;
    showMessage('-- Setting ----- ' +
               (' baudrate :' + inttostr(DCB.Baudrate) +
               (' byteReadSize : 8'  + '  parity : None' +
               (' hcomm :' + inttostr(DCB.id)))));
EscapeCommFunction(hComm, 0);
EscapeCommFunction(hComm, 1);
EscapeCommFunction(hComm, 2);
    end;
end;


end.

