using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class QuizQuestion
{
    public Guid QuestionId { get; set; }

    public Guid QuizId { get; set; }

    public Guid? WordId { get; set; }

    public string QuestionText { get; set; } = null!;

    public string? Explanation { get; set; }

    public int DisplayOrder { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Quiz Quiz { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();

    public virtual QuizQuestionOption? QuizQuestionOption { get; set; }

    public virtual VocabularyWord? Word { get; set; }
}
