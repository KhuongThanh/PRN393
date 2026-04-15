using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class QuizQuestionOption
{
    public Guid OptionId { get; set; }

    public Guid QuestionId { get; set; }

    public string OptionText { get; set; } = null!;

    public bool IsCorrect { get; set; }

    public int DisplayOrder { get; set; }

    public virtual QuizQuestion Question { get; set; } = null!;

    public virtual ICollection<QuizAttemptAnswer> QuizAttemptAnswers { get; set; } = new List<QuizAttemptAnswer>();
}
