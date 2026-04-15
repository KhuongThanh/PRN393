using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class StudySessionDetail
{
    public Guid SessionDetailId { get; set; }

    public Guid SessionId { get; set; }

    public Guid WordId { get; set; }

    public bool IsRemembered { get; set; }

    public int ReviewOrder { get; set; }

    public DateTime ReviewedAt { get; set; }

    public virtual StudySession Session { get; set; } = null!;

    public virtual VocabularyWord Word { get; set; } = null!;
}
