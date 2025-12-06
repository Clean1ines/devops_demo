using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
var app = builder.Build();

app.MapGet("/", () => "Neolant .NET API v1.0");
app.MapGet("/health", () => JsonSerializer.Serialize(new {
    status = "healthy",
    service = "dotnet-api",
    timestamp = DateTime.UtcNow
}));
app.MapGet("/api/industrial-objects", () => JsonSerializer.Serialize(new[] {
    new { id = 1, name = "Белоярская АЭС", type = "АЭС", location = "Свердловская область" },
    new { id = 2, name = "Сургутская ГРЭС-2", type = "ТЭЦ", location = "ХМАО-Югра" },
    new { id = 3, name = "Нововоронежская АЭС", type = "АЭС", location = "Воронежская область" }
}));
app.MapGet("/api/equipment/{objectId}", (int objectId) => JsonSerializer.Serialize(new[] {
    new { id = 1, name = "Турбина Т-250", objectId = objectId, status = "operational" },
    new { id = 2, name = "Генератор ГСВ-1500", objectId = objectId, status = "operational" }
}));

app.Run();
