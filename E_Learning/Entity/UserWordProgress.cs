using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class UserWordProgress
{
    public Guid ProgressId { get; set; }

    public Guid UserId { get; set; }

    public Guid WordId { get; set; }

    public bool IsLearned { get; set; }

    public int CorrectCount { get; set; }

    public int IncorrectCount { get; set; }

    public DateTime? LastStudiedAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual User User { get; set; } = null!;

    public virtual VocabularyWord Word { get; set; } = null!;
}
