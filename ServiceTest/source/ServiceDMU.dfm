object ServiceDM: TServiceDM
  OldCreateOrder = False
  DisplayName = 'X'#178'Log Test Service'
  OnStart = ServiceStart
  Height = 150
  Width = 215
  object tmrLog: TTimer
    Interval = 5000
    OnTimer = tmrLogTimer
    Left = 88
    Top = 56
  end
end
