using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class QuizAttemptAnswer
{
    public Guid AttemptAnswerId { get; set; }

    public Guid AttemptId { get; set; }

    public Guid QuestionId { get; set; }

    public Guid? SelectedOptionId { get; set; }

    public bool IsCorrect { get; set; }

    public DateTime AnsweredAt { get; set; }

    public virtual QuizAttempt Attempt { get; set; } = null!;

    public virtual QuizQuestion Question { get; set; } = null!;

    public virtual QuizQuestionOption? QuizQuestionOption { get; set; }
}
