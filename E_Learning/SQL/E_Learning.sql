/*
=========================================================
ENGLISH VOCABULARY APP - MVP 2 WEEKS
SQL Server / T-SQL
Revised schema: tighter constraints, cleaner defaults,
safer quiz relationships, and more consistent types.
=========================================================

Key improvements:
- Use NEWSEQUENTIALID() for clustered PK GUID defaults
- Use SYSDATETIME() consistently with DATETIME2(7)
- Replace NVARCHAR(MAX) where a bounded size is enough
- Add CHECK constraints for counts, ranges, and timestamps
- Prevent duplicate answers per question in one attempt
- Ensure a selected option belongs to the same question
- Enforce at most one correct option per question
- Add a few practical unique constraints for ordering/data quality
=========================================================
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

/* =========================================================
   OPTIONAL RESET BLOCK
   Uncomment if you want to recreate the whole schema
========================================================= */
/*
IF OBJECT_ID('dbo.QuizAttemptAnswers', 'U') IS NOT NULL DROP TABLE dbo.QuizAttemptAnswers;
IF OBJECT_ID('dbo.QuizAttempts', 'U') IS NOT NULL DROP TABLE dbo.QuizAttempts;
IF OBJECT_ID('dbo.QuizQuestionOptions', 'U') IS NOT NULL DROP TABLE dbo.QuizQuestionOptions;
IF OBJECT_ID('dbo.QuizQuestions', 'U') IS NOT NULL DROP TABLE dbo.QuizQuestions;
IF OBJECT_ID('dbo.Quizzes', 'U') IS NOT NULL DROP TABLE dbo.Quizzes;

IF OBJECT_ID('dbo.StudySessionDetails', 'U') IS NOT NULL DROP TABLE dbo.StudySessionDetails;
IF OBJECT_ID('dbo.StudySessions', 'U') IS NOT NULL DROP TABLE dbo.StudySessions;

IF OBJECT_ID('dbo.UserWordProgress', 'U') IS NOT NULL DROP TABLE dbo.UserWordProgress;
IF OBJECT_ID('dbo.UserFavoriteWords', 'U') IS NOT NULL DROP TABLE dbo.UserFavoriteWords;

IF OBJECT_ID('dbo.VocabularyWords', 'U') IS NOT NULL DROP TABLE dbo.VocabularyWords;
IF OBJECT_ID('dbo.VocabularyTopics', 'U') IS NOT NULL DROP TABLE dbo.VocabularyTopics;

IF OBJECT_ID('dbo.UserProfiles', 'U') IS NOT NULL DROP TABLE dbo.UserProfiles;
IF OBJECT_ID('dbo.UserRoles', 'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO
*/
Use master;
GO
CREATE DATABASE E_Learning;
GO
USE E_Learning;
/* =========================================================
   AUTH TABLES
========================================================= */

CREATE TABLE dbo.Users
(
    UserId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_Users PRIMARY KEY
        CONSTRAINT DF_Users_UserId DEFAULT NEWSEQUENTIALID(),

    UserName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Users_IsActive DEFAULT 1,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT UQ_Users_UserName UNIQUE (UserName),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),

    CONSTRAINT CK_Users_UserName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(UserName))) > 0),

    CONSTRAINT CK_Users_Email_NotBlank
        CHECK (LEN(LTRIM(RTRIM(Email))) > 0),

    CONSTRAINT CK_Users_PasswordHash_NotBlank
        CHECK (LEN(LTRIM(RTRIM(PasswordHash))) > 0)
);
GO

CREATE TABLE dbo.Roles
(
    RoleId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_Roles PRIMARY KEY
        CONSTRAINT DF_Roles_RoleId DEFAULT NEWSEQUENTIALID(),

    RoleName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255) NULL,

    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName),

    CONSTRAINT CK_Roles_RoleName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(RoleName))) > 0)
);
GO

CREATE TABLE dbo.UserRoles
(
    UserId UNIQUEIDENTIFIER NOT NULL,
    RoleId UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT PK_UserRoles PRIMARY KEY (UserId, RoleId),

    CONSTRAINT FK_UserRoles_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT FK_UserRoles_Roles_RoleId FOREIGN KEY (RoleId)
        REFERENCES dbo.Roles(RoleId)
        ON DELETE CASCADE
);
GO

CREATE TABLE dbo.UserProfiles
(
    ProfileId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_UserProfiles PRIMARY KEY
        CONSTRAINT DF_UserProfiles_ProfileId DEFAULT NEWSEQUENTIALID(),

    UserId UNIQUEIDENTIFIER NOT NULL,
    FullName NVARCHAR(150) NULL,
    AvatarUrl NVARCHAR(500) NULL,
    TargetDailyWords INT NOT NULL
        CONSTRAINT DF_UserProfiles_TargetDailyWords DEFAULT 10,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_UserProfiles_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT UQ_UserProfiles_UserId UNIQUE (UserId),

    CONSTRAINT FK_UserProfiles_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT CK_UserProfiles_TargetDailyWords
        CHECK (TargetDailyWords BETWEEN 1 AND 500)
);
GO

/* =========================================================
   VOCABULARY TABLES
========================================================= */

CREATE TABLE dbo.VocabularyTopics
(
    TopicId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_VocabularyTopics PRIMARY KEY
        CONSTRAINT DF_VocabularyTopics_TopicId DEFAULT NEWSEQUENTIALID(),

    TopicName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    ImageUrl NVARCHAR(500) NULL,
    DisplayOrder INT NOT NULL
        CONSTRAINT DF_VocabularyTopics_DisplayOrder DEFAULT 0,
    IsActive BIT NOT NULL
        CONSTRAINT DF_VocabularyTopics_IsActive DEFAULT 1,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_VocabularyTopics_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT UQ_VocabularyTopics_TopicName UNIQUE (TopicName),

    CONSTRAINT CK_VocabularyTopics_TopicName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(TopicName))) > 0),

    CONSTRAINT CK_VocabularyTopics_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

CREATE TABLE dbo.VocabularyWords
(
    WordId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_VocabularyWords PRIMARY KEY
        CONSTRAINT DF_VocabularyWords_WordId DEFAULT NEWSEQUENTIALID(),

    TopicId UNIQUEIDENTIFIER NOT NULL,

    WordText NVARCHAR(100) NOT NULL,
    Meaning NVARCHAR(255) NOT NULL,
    ExampleSentence NVARCHAR(500) NULL,
    PartOfSpeech NVARCHAR(50) NULL,
    Phonetic NVARCHAR(100) NULL,
    AudioUrl NVARCHAR(500) NULL,
    ImageUrl NVARCHAR(500) NULL,
    DifficultyLevel NVARCHAR(20) NOT NULL
        CONSTRAINT DF_VocabularyWords_DifficultyLevel DEFAULT N'Beginner',
    IsActive BIT NOT NULL
        CONSTRAINT DF_VocabularyWords_IsActive DEFAULT 1,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_VocabularyWords_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT FK_VocabularyWords_VocabularyTopics_TopicId FOREIGN KEY (TopicId)
        REFERENCES dbo.VocabularyTopics(TopicId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_VocabularyWords_TopicId_WordText UNIQUE (TopicId, WordText),

    CONSTRAINT CK_VocabularyWords_WordText_NotBlank
        CHECK (LEN(LTRIM(RTRIM(WordText))) > 0),

    CONSTRAINT CK_VocabularyWords_Meaning_NotBlank
        CHECK (LEN(LTRIM(RTRIM(Meaning))) > 0),

    CONSTRAINT CK_VocabularyWords_DifficultyLevel CHECK (
        DifficultyLevel IN (N'Beginner', N'Intermediate', N'Advanced')
    )
);
GO

CREATE TABLE dbo.UserFavoriteWords
(
    UserId UNIQUEIDENTIFIER NOT NULL,
    WordId UNIQUEIDENTIFIER NOT NULL,

    AddedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_UserFavoriteWords_AddedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_UserFavoriteWords PRIMARY KEY (UserId, WordId),

    CONSTRAINT FK_UserFavoriteWords_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT FK_UserFavoriteWords_VocabularyWords_WordId FOREIGN KEY (WordId)
        REFERENCES dbo.VocabularyWords(WordId)
        ON DELETE CASCADE
);
GO

CREATE TABLE dbo.UserWordProgress
(
    ProgressId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_UserWordProgress PRIMARY KEY
        CONSTRAINT DF_UserWordProgress_ProgressId DEFAULT NEWSEQUENTIALID(),

    UserId UNIQUEIDENTIFIER NOT NULL,
    WordId UNIQUEIDENTIFIER NOT NULL,

    IsLearned BIT NOT NULL
        CONSTRAINT DF_UserWordProgress_IsLearned DEFAULT 0,

    CorrectCount INT NOT NULL
        CONSTRAINT DF_UserWordProgress_CorrectCount DEFAULT 0,

    IncorrectCount INT NOT NULL
        CONSTRAINT DF_UserWordProgress_IncorrectCount DEFAULT 0,

    LastStudiedAt DATETIME2(7) NULL,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_UserWordProgress_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT UQ_UserWordProgress_UserId_WordId UNIQUE (UserId, WordId),

    CONSTRAINT FK_UserWordProgress_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT FK_UserWordProgress_VocabularyWords_WordId FOREIGN KEY (WordId)
        REFERENCES dbo.VocabularyWords(WordId)
        ON DELETE CASCADE,

    CONSTRAINT CK_UserWordProgress_CorrectCount
        CHECK (CorrectCount >= 0),

    CONSTRAINT CK_UserWordProgress_IncorrectCount
        CHECK (IncorrectCount >= 0)
);
GO

/* =========================================================
   FLASHCARD STUDY TABLES
========================================================= */

CREATE TABLE dbo.StudySessions
(
    SessionId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_StudySessions PRIMARY KEY
        CONSTRAINT DF_StudySessions_SessionId DEFAULT NEWSEQUENTIALID(),

    UserId UNIQUEIDENTIFIER NOT NULL,
    TopicId UNIQUEIDENTIFIER NULL,

    SessionType NVARCHAR(20) NOT NULL
        CONSTRAINT DF_StudySessions_SessionType DEFAULT N'Flashcard',

    StartedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_StudySessions_StartedAt DEFAULT SYSDATETIME(),

    EndedAt DATETIME2(7) NULL,

    TotalWords INT NOT NULL
        CONSTRAINT DF_StudySessions_TotalWords DEFAULT 0,

    RememberedCount INT NOT NULL
        CONSTRAINT DF_StudySessions_RememberedCount DEFAULT 0,

    NotRememberedCount INT NOT NULL
        CONSTRAINT DF_StudySessions_NotRememberedCount DEFAULT 0,

    CONSTRAINT FK_StudySessions_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT FK_StudySessions_VocabularyTopics_TopicId FOREIGN KEY (TopicId)
        REFERENCES dbo.VocabularyTopics(TopicId),

    CONSTRAINT CK_StudySessions_SessionType
        CHECK (SessionType IN (N'Flashcard')),

    CONSTRAINT CK_StudySessions_TotalWords
        CHECK (TotalWords >= 0),

    CONSTRAINT CK_StudySessions_RememberedCount
        CHECK (RememberedCount >= 0),

    CONSTRAINT CK_StudySessions_NotRememberedCount
        CHECK (NotRememberedCount >= 0),

    CONSTRAINT CK_StudySessions_CountsWithinTotal
        CHECK (RememberedCount + NotRememberedCount <= TotalWords),

    CONSTRAINT CK_StudySessions_EndedAt
        CHECK (EndedAt IS NULL OR EndedAt >= StartedAt)
);
GO

CREATE TABLE dbo.StudySessionDetails
(
    SessionDetailId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_StudySessionDetails PRIMARY KEY
        CONSTRAINT DF_StudySessionDetails_SessionDetailId DEFAULT NEWSEQUENTIALID(),

    SessionId UNIQUEIDENTIFIER NOT NULL,
    WordId UNIQUEIDENTIFIER NOT NULL,

    IsRemembered BIT NOT NULL,

    ReviewOrder INT NOT NULL
        CONSTRAINT DF_StudySessionDetails_ReviewOrder DEFAULT 0,

    ReviewedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_StudySessionDetails_ReviewedAt DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_StudySessionDetails_SessionId_WordId UNIQUE (SessionId, WordId),

    CONSTRAINT FK_StudySessionDetails_StudySessions_SessionId FOREIGN KEY (SessionId)
        REFERENCES dbo.StudySessions(SessionId)
        ON DELETE CASCADE,

    CONSTRAINT FK_StudySessionDetails_VocabularyWords_WordId FOREIGN KEY (WordId)
        REFERENCES dbo.VocabularyWords(WordId),

    CONSTRAINT CK_StudySessionDetails_ReviewOrder
        CHECK (ReviewOrder >= 0)
);
GO

/* =========================================================
   QUIZ TABLES
   Designed to avoid SQL Server multiple cascade paths
========================================================= */

CREATE TABLE dbo.Quizzes
(
    QuizId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_Quizzes PRIMARY KEY
        CONSTRAINT DF_Quizzes_QuizId DEFAULT NEWSEQUENTIALID(),

    TopicId UNIQUEIDENTIFIER NOT NULL,
    QuizTitle NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    TimeLimitMinutes INT NULL,
    IsActive BIT NOT NULL
        CONSTRAINT DF_Quizzes_IsActive DEFAULT 1,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_Quizzes_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2(7) NULL,

    CONSTRAINT FK_Quizzes_VocabularyTopics_TopicId FOREIGN KEY (TopicId)
        REFERENCES dbo.VocabularyTopics(TopicId),

    CONSTRAINT CK_Quizzes_QuizTitle_NotBlank
        CHECK (LEN(LTRIM(RTRIM(QuizTitle))) > 0),

    CONSTRAINT CK_Quizzes_TimeLimitMinutes
        CHECK (TimeLimitMinutes IS NULL OR TimeLimitMinutes BETWEEN 1 AND 180)
);
GO

CREATE TABLE dbo.QuizQuestions
(
    QuestionId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_QuizQuestions PRIMARY KEY
        CONSTRAINT DF_QuizQuestions_QuestionId DEFAULT NEWSEQUENTIALID(),

    QuizId UNIQUEIDENTIFIER NOT NULL,
    WordId UNIQUEIDENTIFIER NULL,

    QuestionText NVARCHAR(500) NOT NULL,
    Explanation NVARCHAR(500) NULL,
    DisplayOrder INT NOT NULL
        CONSTRAINT DF_QuizQuestions_DisplayOrder DEFAULT 0,

    CreatedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_QuizQuestions_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT FK_QuizQuestions_Quizzes_QuizId FOREIGN KEY (QuizId)
        REFERENCES dbo.Quizzes(QuizId)
        ON DELETE CASCADE,

    CONSTRAINT FK_QuizQuestions_VocabularyWords_WordId FOREIGN KEY (WordId)
        REFERENCES dbo.VocabularyWords(WordId),

    CONSTRAINT UQ_QuizQuestions_QuizId_DisplayOrder UNIQUE (QuizId, DisplayOrder),

    CONSTRAINT CK_QuizQuestions_QuestionText_NotBlank
        CHECK (LEN(LTRIM(RTRIM(QuestionText))) > 0),

    CONSTRAINT CK_QuizQuestions_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

CREATE TABLE dbo.QuizQuestionOptions
(
    OptionId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_QuizQuestionOptions PRIMARY KEY
        CONSTRAINT DF_QuizQuestionOptions_OptionId DEFAULT NEWSEQUENTIALID(),

    QuestionId UNIQUEIDENTIFIER NOT NULL,
    OptionText NVARCHAR(255) NOT NULL,
    IsCorrect BIT NOT NULL
        CONSTRAINT DF_QuizQuestionOptions_IsCorrect DEFAULT 0,
    DisplayOrder INT NOT NULL
        CONSTRAINT DF_QuizQuestionOptions_DisplayOrder DEFAULT 0,

    CONSTRAINT UQ_QuizQuestionOptions_QuestionId_OptionId UNIQUE (QuestionId, OptionId),
    CONSTRAINT UQ_QuizQuestionOptions_QuestionId_DisplayOrder UNIQUE (QuestionId, DisplayOrder),

    CONSTRAINT FK_QuizQuestionOptions_QuizQuestions_QuestionId FOREIGN KEY (QuestionId)
        REFERENCES dbo.QuizQuestions(QuestionId)
        ON DELETE CASCADE,

    CONSTRAINT CK_QuizQuestionOptions_OptionText_NotBlank
        CHECK (LEN(LTRIM(RTRIM(OptionText))) > 0),

    CONSTRAINT CK_QuizQuestionOptions_DisplayOrder
        CHECK (DisplayOrder >= 0)
);
GO

CREATE TABLE dbo.QuizAttempts
(
    AttemptId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_QuizAttempts PRIMARY KEY
        CONSTRAINT DF_QuizAttempts_AttemptId DEFAULT NEWSEQUENTIALID(),

    QuizId UNIQUEIDENTIFIER NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,

    StartedAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_QuizAttempts_StartedAt DEFAULT SYSDATETIME(),

    SubmittedAt DATETIME2(7) NULL,

    Score DECIMAL(5,2) NULL,
    TotalQuestions INT NOT NULL
        CONSTRAINT DF_QuizAttempts_TotalQuestions DEFAULT 0,
    CorrectAnswers INT NOT NULL
        CONSTRAINT DF_QuizAttempts_CorrectAnswers DEFAULT 0,

    CONSTRAINT FK_QuizAttempts_Quizzes_QuizId FOREIGN KEY (QuizId)
        REFERENCES dbo.Quizzes(QuizId),

    CONSTRAINT FK_QuizAttempts_Users_UserId FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId)
        ON DELETE CASCADE,

    CONSTRAINT CK_QuizAttempts_TotalQuestions
        CHECK (TotalQuestions >= 0),

    CONSTRAINT CK_QuizAttempts_CorrectAnswers
        CHECK (CorrectAnswers >= 0 AND CorrectAnswers <= TotalQuestions),

    CONSTRAINT CK_QuizAttempts_Score
        CHECK (Score IS NULL OR (Score >= 0 AND Score <= 100)),

    CONSTRAINT CK_QuizAttempts_SubmittedAt
        CHECK (SubmittedAt IS NULL OR SubmittedAt >= StartedAt)
);
GO

CREATE TABLE dbo.QuizAttemptAnswers
(
    AttemptAnswerId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_QuizAttemptAnswers PRIMARY KEY
        CONSTRAINT DF_QuizAttemptAnswers_AttemptAnswerId DEFAULT NEWSEQUENTIALID(),

    AttemptId UNIQUEIDENTIFIER NOT NULL,
    QuestionId UNIQUEIDENTIFIER NOT NULL,
    SelectedOptionId UNIQUEIDENTIFIER NULL,

    IsCorrect BIT NOT NULL,

    AnsweredAt DATETIME2(7) NOT NULL
        CONSTRAINT DF_QuizAttemptAnswers_AnsweredAt DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_QuizAttemptAnswers_AttemptId_QuestionId UNIQUE (AttemptId, QuestionId),

    CONSTRAINT FK_QuizAttemptAnswers_QuizAttempts_AttemptId FOREIGN KEY (AttemptId)
        REFERENCES dbo.QuizAttempts(AttemptId)
        ON DELETE CASCADE,

    CONSTRAINT FK_QuizAttemptAnswers_QuizQuestions_QuestionId FOREIGN KEY (QuestionId)
        REFERENCES dbo.QuizQuestions(QuestionId),

    CONSTRAINT FK_QuizAttemptAnswers_QuestionOptionMatch FOREIGN KEY (QuestionId, SelectedOptionId)
        REFERENCES dbo.QuizQuestionOptions(QuestionId, OptionId)
);
GO

/* =========================================================
   INDEXES
========================================================= */

CREATE INDEX IX_UserRoles_RoleId
    ON dbo.UserRoles(RoleId);
GO

CREATE INDEX IX_UserProfiles_UserId
    ON dbo.UserProfiles(UserId);
GO

CREATE INDEX IX_VocabularyWords_TopicId
    ON dbo.VocabularyWords(TopicId);
GO

CREATE INDEX IX_VocabularyWords_WordText
    ON dbo.VocabularyWords(WordText);
GO

CREATE INDEX IX_UserFavoriteWords_WordId
    ON dbo.UserFavoriteWords(WordId);
GO

CREATE INDEX IX_UserWordProgress_UserId
    ON dbo.UserWordProgress(UserId);
GO

CREATE INDEX IX_UserWordProgress_WordId
    ON dbo.UserWordProgress(WordId);
GO

CREATE INDEX IX_StudySessions_UserId
    ON dbo.StudySessions(UserId);
GO

CREATE INDEX IX_StudySessions_TopicId
    ON dbo.StudySessions(TopicId);
GO

CREATE INDEX IX_StudySessionDetails_SessionId
    ON dbo.StudySessionDetails(SessionId);
GO

CREATE INDEX IX_StudySessionDetails_WordId
    ON dbo.StudySessionDetails(WordId);
GO

CREATE INDEX IX_Quizzes_TopicId
    ON dbo.Quizzes(TopicId);
GO

CREATE INDEX IX_QuizQuestions_QuizId
    ON dbo.QuizQuestions(QuizId);
GO

CREATE INDEX IX_QuizQuestionOptions_QuestionId
    ON dbo.QuizQuestionOptions(QuestionId);
GO

CREATE UNIQUE INDEX UX_QuizQuestionOptions_OneCorrectPerQuestion
    ON dbo.QuizQuestionOptions(QuestionId)
    WHERE IsCorrect = 1;
GO

CREATE INDEX IX_QuizAttempts_QuizId
    ON dbo.QuizAttempts(QuizId);
GO

CREATE INDEX IX_QuizAttempts_UserId
    ON dbo.QuizAttempts(UserId);
GO

CREATE INDEX IX_QuizAttemptAnswers_AttemptId
    ON dbo.QuizAttemptAnswers(AttemptId);
GO

CREATE INDEX IX_QuizAttemptAnswers_QuestionId
    ON dbo.QuizAttemptAnswers(QuestionId);
GO

/* =========================================================
   SEED DATA
========================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'Admin')
BEGIN
    INSERT INTO dbo.Roles (RoleName, Description)
    VALUES (N'Admin', N'Administrator');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'User')
BEGIN
    INSERT INTO dbo.Roles (RoleName, Description)
    VALUES (N'User', N'Normal user');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.VocabularyTopics WHERE TopicName = N'Daily Life')
BEGIN
    INSERT INTO dbo.VocabularyTopics (TopicName, Description, DisplayOrder)
    VALUES (N'Daily Life', N'Basic daily vocabulary', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.VocabularyTopics WHERE TopicName = N'Education')
BEGIN
    INSERT INTO dbo.VocabularyTopics (TopicName, Description, DisplayOrder)
    VALUES (N'Education', N'School and study vocabulary', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.VocabularyTopics WHERE TopicName = N'Travel')
BEGIN
    INSERT INTO dbo.VocabularyTopics (TopicName, Description, DisplayOrder)
    VALUES (N'Travel', N'Travel vocabulary', 3);
END
GO

DECLARE @DailyLifeTopicId UNIQUEIDENTIFIER;

SELECT TOP 1 @DailyLifeTopicId = TopicId
FROM dbo.VocabularyTopics
WHERE TopicName = N'Daily Life';

IF @DailyLifeTopicId IS NOT NULL
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VocabularyWords
        WHERE TopicId = @DailyLifeTopicId
          AND WordText = N'apple'
    )
    BEGIN
        INSERT INTO dbo.VocabularyWords
        (
            TopicId,
            WordText,
            Meaning,
            ExampleSentence,
            PartOfSpeech,
            Phonetic,
            DifficultyLevel
        )
        VALUES
        (
            @DailyLifeTopicId,
            N'apple',
            N'quả táo',
            N'I eat an apple every day.',
            N'noun',
            N'/ˈæp.əl/',
            N'Beginner'
        );
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VocabularyWords
        WHERE TopicId = @DailyLifeTopicId
          AND WordText = N'book'
    )
    BEGIN
        INSERT INTO dbo.VocabularyWords
        (
            TopicId,
            WordText,
            Meaning,
            ExampleSentence,
            PartOfSpeech,
            Phonetic,
            DifficultyLevel
        )
        VALUES
        (
            @DailyLifeTopicId,
            N'book',
            N'quyển sách',
            N'This book is very useful.',
            N'noun',
            N'/bʊk/',
            N'Beginner'
        );
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.VocabularyWords
        WHERE TopicId = @DailyLifeTopicId
          AND WordText = N'beautiful'
    )
    BEGIN
        INSERT INTO dbo.VocabularyWords
        (
            TopicId,
            WordText,
            Meaning,
            ExampleSentence,
            PartOfSpeech,
            Phonetic,
            DifficultyLevel
        )
        VALUES
        (
            @DailyLifeTopicId,
            N'beautiful',
            N'đẹp',
            N'The garden is beautiful.',
            N'adjective',
            N'/ˈbjuː.tɪ.fəl/',
            N'Beginner'
        );
    END
END
GO

/*
=========================================================
NOTES
=========================================================
1. This schema enforces "at most one correct option" per question
   by using a filtered unique index.
2. SQL Server cannot conveniently enforce "at least one correct option"
   with a simple CHECK constraint. That rule is usually handled in:
   - application/service layer, or
   - a trigger/stored procedure.
3. Topic/Quiz delete behavior is intentionally restrictive in a few places
   to avoid accidental data loss and multiple cascade path issues.
=========================================================
*/
