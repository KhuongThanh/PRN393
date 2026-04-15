using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class QuizAttempt
{
    public Guid AttemptId { get; set; }

    public Guid QuizId { get; set; }

    public Guid UserId { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime? SubmittedAt { get; set; }

    public decimal? Score { get; set; }

    public int TotalQuestions { get; set; }

    public int CorrectAnswers { get; set; }

    public virtual Quiz Quiz { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();

    public virtual User User { get; set; } = null!;
}
