using System;
using System.Collections.Generic;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;

namespace E_Learning.Data;

public partial class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Quiz> Quizzes { get; set; }

    public virtual DbSet<QuizAttempt> QuizAttempts { get; set; }

    public virtual DbSet<QuizAttemptAnswer> QuizAttemptAnswers { get; set; }

    public virtual DbSet<QuizQuestion> QuizQuestions { get; set; }

    public virtual DbSet<QuizQuestionOption> QuizQuestionOptions { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<StudySession> StudySessions { get; set; }

    public virtual DbSet<StudySessionDetail> StudySessionDetails { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserFavoriteWord> UserFavoriteWords { get; set; }

    public virtual DbSet<UserProfile> UserProfiles { get; set; }

    public virtual DbSet<UserWordProgress> UserWordProgresses { get; set; }

    public virtual DbSet<VocabularyTopic> VocabularyTopics { get; set; }

    public virtual DbSet<VocabularyWord> VocabularyWords { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Quiz>(entity =>
        {
            entity.HasIndex(e => e.TopicId, "IX_Quizzes_TopicId");

            entity.Property(e => e.QuizId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.QuizTitle).HasMaxLength(150);

            entity.HasOne(d => d.Topic).WithMany(p => p.Quizzes)
                .HasForeignKey(d => d.TopicId)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<QuizAttempt>(entity =>
        {
            entity.HasKey(e => e.AttemptId);

            entity.HasIndex(e => e.QuizId, "IX_QuizAttempts_QuizId");

            entity.HasIndex(e => e.UserId, "IX_QuizAttempts_UserId");

            entity.Property(e => e.AttemptId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.Score).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.StartedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Quiz).WithMany(p => p.QuizAttempts)
                .HasForeignKey(d => d.QuizId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.User).WithMany(p => p.QuizAttempts).HasForeignKey(d => d.UserId);
        });

        modelBuilder.Entity<QuizAttemptAnswer>(entity =>
        {
            entity.HasKey(e => e.AttemptAnswerId);

            entity.HasIndex(e => e.AttemptId, "IX_QuizAttemptAnswers_AttemptId");

            entity.HasIndex(e => e.QuestionId, "IX_QuizAttemptAnswers_QuestionId");

            entity.HasIndex(e => new { e.AttemptId, e.QuestionId }, "UQ_QuizAttemptAnswers_AttemptId_QuestionId").IsUnique();

            entity.Property(e => e.AttemptAnswerId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.AnsweredAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Attempt).WithMany(p => p.QuizAttemptAnswers).HasForeignKey(d => d.AttemptId);

            entity.HasOne(d => d.Question).WithMany(p => p.QuizAttemptAnswers)
                .HasForeignKey(d => d.QuestionId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.QuizQuestionOption).WithMany(p => p.QuizAttemptAnswers)
                .HasPrincipalKey(p => new { p.QuestionId, p.OptionId })
                .HasForeignKey(d => new { d.QuestionId, d.SelectedOptionId })
                .HasConstraintName("FK_QuizAttemptAnswers_QuestionOptionMatch");
        });

        modelBuilder.Entity<QuizQuestion>(entity =>
        {
            entity.HasKey(e => e.QuestionId);

            entity.HasIndex(e => e.QuizId, "IX_QuizQuestions_QuizId");

            entity.HasIndex(e => new { e.QuizId, e.DisplayOrder }, "UQ_QuizQuestions_QuizId_DisplayOrder").IsUnique();

            entity.Property(e => e.QuestionId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Explanation).HasMaxLength(500);
            entity.Property(e => e.QuestionText).HasMaxLength(500);

            entity.HasOne(d => d.Quiz).WithMany(p => p.QuizQuestions).HasForeignKey(d => d.QuizId);

            entity.HasOne(d => d.Word).WithMany(p => p.QuizQuestions).HasForeignKey(d => d.WordId);
        });

        modelBuilder.Entity<QuizQuestionOption>(entity =>
        {
            entity.HasKey(e => e.OptionId);

            entity.HasIndex(e => e.QuestionId, "IX_QuizQuestionOptions_QuestionId");

            entity.HasIndex(e => new { e.QuestionId, e.DisplayOrder }, "UQ_QuizQuestionOptions_QuestionId_DisplayOrder").IsUnique();

            entity.HasIndex(e => new { e.QuestionId, e.OptionId }, "UQ_QuizQuestionOptions_QuestionId_OptionId").IsUnique();

            entity.HasIndex(e => e.QuestionId, "UX_QuizQuestionOptions_OneCorrectPerQuestion")
                .IsUnique()
                .HasFilter("([IsCorrect]=(1))");

            entity.Property(e => e.OptionId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.OptionText).HasMaxLength(255);

            entity.HasOne(d => d.Question).WithOne(p => p.QuizQuestionOption).HasForeignKey<QuizQuestionOption>(d => d.QuestionId);
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasIndex(e => e.RoleName, "UQ_Roles_RoleName").IsUnique();

            entity.Property(e => e.RoleId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.Description).HasMaxLength(255);
            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<StudySession>(entity =>
        {
            entity.HasKey(e => e.SessionId);

            entity.HasIndex(e => e.TopicId, "IX_StudySessions_TopicId");

            entity.HasIndex(e => e.UserId, "IX_StudySessions_UserId");

            entity.Property(e => e.SessionId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.SessionType)
                .HasMaxLength(20)
                .HasDefaultValue("Flashcard");
            entity.Property(e => e.SourceName).HasMaxLength(100);
            entity.Property(e => e.SourceType)
                .HasMaxLength(20)
                .HasDefaultValue("Topic");
            entity.Property(e => e.StartedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Topic).WithMany(p => p.StudySessions).HasForeignKey(d => d.TopicId);

            entity.HasOne(d => d.User).WithMany(p => p.StudySessions).HasForeignKey(d => d.UserId);
        });

        modelBuilder.Entity<StudySessionDetail>(entity =>
        {
            entity.HasKey(e => e.SessionDetailId);

            entity.HasIndex(e => e.SessionId, "IX_StudySessionDetails_SessionId");

            entity.HasIndex(e => e.WordId, "IX_StudySessionDetails_WordId");

            entity.HasIndex(e => new { e.SessionId, e.WordId }, "UQ_StudySessionDetails_SessionId_WordId").IsUnique();

            entity.Property(e => e.SessionDetailId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.ReviewedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Session).WithMany(p => p.StudySessionDetails).HasForeignKey(d => d.SessionId);

            entity.HasOne(d => d.Word).WithMany(p => p.StudySessionDetails)
                .HasForeignKey(d => d.WordId)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Email, "UQ_Users_Email").IsUnique();

            entity.HasIndex(e => e.UserName, "UQ_Users_UserName").IsUnique();

            entity.Property(e => e.UserId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.UserName).HasMaxLength(100);

            entity.HasMany(d => d.Roles).WithMany(p => p.Users)
                .UsingEntity<Dictionary<string, object>>(
                    "UserRole",
                    r => r.HasOne<Role>().WithMany().HasForeignKey("RoleId"),
                    l => l.HasOne<User>().WithMany().HasForeignKey("UserId"),
                    j =>
                    {
                        j.HasKey("UserId", "RoleId");
                        j.ToTable("UserRoles");
                        j.HasIndex(new[] { "RoleId" }, "IX_UserRoles_RoleId");
                    });
        });

        modelBuilder.Entity<UserFavoriteWord>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.WordId });

            entity.HasIndex(e => e.WordId, "IX_UserFavoriteWords_WordId");

            entity.Property(e => e.AddedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.User).WithMany(p => p.UserFavoriteWords).HasForeignKey(d => d.UserId);

            entity.HasOne(d => d.Word).WithMany(p => p.UserFavoriteWords).HasForeignKey(d => d.WordId);
        });

        modelBuilder.Entity<UserProfile>(entity =>
        {
            entity.HasKey(e => e.ProfileId);

            entity.HasIndex(e => e.UserId, "IX_UserProfiles_UserId");

            entity.HasIndex(e => e.UserId, "UQ_UserProfiles_UserId").IsUnique();

            entity.Property(e => e.ProfileId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.AvatarUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.TargetDailyWords).HasDefaultValue(10);

            entity.HasOne(d => d.User).WithOne(p => p.UserProfile).HasForeignKey<UserProfile>(d => d.UserId);
        });

        modelBuilder.Entity<UserWordProgress>(entity =>
        {
            entity.HasKey(e => e.ProgressId);

            entity.ToTable("UserWordProgress");

            entity.HasIndex(e => e.UserId, "IX_UserWordProgress_UserId");

            entity.HasIndex(e => e.WordId, "IX_UserWordProgress_WordId");

            entity.HasIndex(e => new { e.UserId, e.WordId }, "UQ_UserWordProgress_UserId_WordId").IsUnique();

            entity.Property(e => e.ProgressId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.User).WithMany(p => p.UserWordProgresses).HasForeignKey(d => d.UserId);

            entity.HasOne(d => d.Word).WithMany(p => p.UserWordProgresses).HasForeignKey(d => d.WordId);
        });

        modelBuilder.Entity<VocabularyTopic>(entity =>
        {
            entity.HasKey(e => e.TopicId);

            entity.HasIndex(e => e.TopicName, "UQ_VocabularyTopics_TopicName").IsUnique();

            entity.Property(e => e.TopicId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.TopicName).HasMaxLength(150);
        });

        modelBuilder.Entity<VocabularyWord>(entity =>
        {
            entity.HasKey(e => e.WordId);

            entity.HasIndex(e => e.TopicId, "IX_VocabularyWords_TopicId");

            entity.HasIndex(e => e.WordText, "IX_VocabularyWords_WordText");

            entity.HasIndex(e => new { e.TopicId, e.WordText }, "UQ_VocabularyWords_TopicId_WordText").IsUnique();

            entity.Property(e => e.WordId).HasDefaultValueSql("(newsequentialid())");
            entity.Property(e => e.AudioUrl).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.DifficultyLevel)
                .HasMaxLength(20)
                .HasDefaultValue("Beginner");
            entity.Property(e => e.ExampleSentence).HasMaxLength(500);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Meaning).HasMaxLength(255);
            entity.Property(e => e.PartOfSpeech).HasMaxLength(50);
            entity.Property(e => e.Phonetic).HasMaxLength(100);
            entity.Property(e => e.WordText).HasMaxLength(100);

            entity.HasOne(d => d.Topic).WithMany(p => p.VocabularyWords).HasForeignKey(d => d.TopicId);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
