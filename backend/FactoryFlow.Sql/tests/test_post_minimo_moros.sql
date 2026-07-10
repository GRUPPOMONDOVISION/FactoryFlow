DECLARE @json nvarchar(max) = N'[
  {"codice":"CAPSULABIALETTI","lotto":"0090","magazzino":"MP","quantita":1},
  {"codice":"CARTAALLUMINIOMICROF","lotto":"JOB 20295","magazzino":"MP","quantita":0.380},
  {"codice":"CARTAFILTRO1","lotto":"47848787","magazzino":"MP","quantita":0.110},
  {"codice":"TOPBIALETTI","lotto":"22-1335-002","magazzino":"MP","quantita":0.220}
]';

EXEC dbo.sp_FactoryFlow_CreaDichiarazioneProduzione
    @CodAzi = 'MOROS',
    @Esercizio = 2023,
    @DataRilevazione = '20231103',
    @ArticoloProdotto = 'CAPSULABIALETTIDIST',
    @LottoProdotto = 'FFTEST0001',
    @MagazzinoProdotto = '01',
    @QuantitaProdotta = 1,
    @ComponentiJson = @json;
