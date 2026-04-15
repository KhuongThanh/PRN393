using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class Quiz
{
    public Guid QuizId { get; set; }

    public Guid TopicId { get; set; }

    public string QuizTitle { get; set; } = null!;

    public string? Description { get; set; }

    public int? TimeLimitMinutes { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<QuizAttempt> QuizAttempts { get; set; } = new List<QuizAttempt>();

    public virtual ICollection<QuizQuestion> QuizQuestions { get; set; } = new List<QuizQuestion>();

    public virtual VocabularyTopic Topic { get; set; } = null!;
}
