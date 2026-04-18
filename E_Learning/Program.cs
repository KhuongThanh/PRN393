using E_Learning.Data;
using E_Learning.Domain.Admin.Options.Interface;
using E_Learning.Domain.Admin.Options.Services;
using E_Learning.Domain.Admin.Questions.Interface;
using E_Learning.Domain.Admin.Questions.Services;
using E_Learning.Domain.Admin.Quizzes.Interface;
using E_Learning.Domain.Admin.Quizzes.Services;
using E_Learning.Domain.Admin.Topics.Interface;
using E_Learning.Domain.Admin.Topics.Services;
using E_Learning.Domain.Admin.Words.Interface;
using E_Learning.Domain.Admin.Words.Services;
using E_Learning.Domain.Auth.Configurations;
using E_Learning.Domain.Auth.Interface;
using E_Learning.Domain.Auth.Services;
using E_Learning.Domain.Dashboard.Interface;
using E_Learning.Domain.Dashboard.Services;
using E_Learning.Domain.Favorite.Interface;
using E_Learning.Domain.Favorite.Services;
using E_Learning.Domain.Progress.Interface;
using E_Learning.Domain.Progress.Services;
using E_Learning.Domain.Quiz.Interface;
using E_Learning.Domain.Quiz.Services;
using E_Learning.Domain.Study.Interface;
using E_Learning.Domain.Study.Services;
using E_Learning.Domain.Vocabulary.Interface;
using E_Learning.Domain.Vocabulary.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("MyDbContext")));
//
builder.Services.Configure<AppSettings>(
    builder.Configuration.GetSection("AppSettings"));

builder.Services.AddHttpContextAccessor();
// JWT
builder.Services.Configure<JwtOptions>(builder.Configuration.GetSection("Jwt"));
var jwtOptions = builder.Configuration.GetSection("Jwt").Get<JwtOptions>()!;

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidAudience = jwtOptions.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtOptions.Key))
        };
    });

builder.Services.AddAuthorization();

// DI
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IFavoriteService, FavoriteService>();
builder.Services.AddScoped<IVocabularyTopicService, VocabularyTopicService>();
builder.Services.AddScoped<IVocabularyWordService, VocabularyWordService>();
builder.Services.AddScoped<IUserWordProgressService, UserWordProgressService>();
builder.Services.AddScoped<IStudySessionService, StudySessionService>();
builder.Services.AddScoped<IQuizCatalogService, QuizCatalogService>();
builder.Services.AddScoped<IQuizAttemptService, QuizAttemptService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddScoped<IAdminTopicService, AdminTopicService>();
builder.Services.AddScoped<IAdminWordService, AdminWordService>();
builder.Services.AddScoped<IAdminQuizService, AdminQuizService>();
builder.Services.AddScoped<IAdminQuestionService, AdminQuestionService>();
builder.Services.AddScoped<IAdminOptionService, AdminOptionService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Swagger + JWT Bearer
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "E-Learning API",
        Version = "v1"
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Nhập token theo dạng: Bearer {your_token}"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();