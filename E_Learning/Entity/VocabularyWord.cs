using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class VocabularyWord
{
    public Guid WordId { get; set; }

    public Guid TopicId { get; set; }

    public string WordText { get; set; } = null!;

    public string Meaning { get; set; } = null!;

    public string? ExampleSentence { get; set; }

    public string? PartOfSpeech { get; set; }

    public string? Phonetic { get; set; }

    public string? AudioUrl { get; set; }

    public string? ImageUrl { get; set; }

    public string DifficultyLevel { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<QuizQuestion> QuizQuestions { get; set; } = new List<QuizQuestion>();

    public virtual ICollection<StudySessionDetail> StudySessionDetails { get; set; } = new List<StudySessionDetail>();

    public virtual VocabularyTopic Topic { get; set; } = null!;

    public virtual ICollection<UserFavoriteWord> UserFavoriteWords { get; set; } = new List<UserFavoriteWord>();

    public virtual ICollection<UserWordProgress> UserWordProgresses { get; set; } = new List<UserWordProgress>();
}
