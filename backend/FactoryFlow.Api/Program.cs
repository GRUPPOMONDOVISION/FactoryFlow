using FactoryFlow.Api.Services;
using FactoryFlow.Core.Interfaces;
using FactoryFlow.Infrastructure.Repositories;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseWindowsService();

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5100);
});

builder.Services.AddScoped<IProduzioneRepository, ProduzioneRepository>();
builder.Services.AddScoped<IConfigurazioneRepository, ConfigurazioneRepository>();
builder.Services.AddScoped<ILineeRepository, LineeRepository>();
builder.Services.AddScoped<IOperatoriRepository, OperatoriRepository>();
builder.Services.AddScoped<ProduzioneService>();
builder.Services.AddScoped<ConfigurazioneService>();
builder.Services.AddScoped<LineeService>();
builder.Services.AddScoped<OperatoriService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseRouting();
app.UseCors("AllowFlutter");
app.UseStaticFiles();
app.UseAuthorization();
app.MapControllers();
app.Run();


