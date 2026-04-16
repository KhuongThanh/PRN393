using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class StudySession
{
    public Guid SessionId { get; set; }

    public Guid UserId { get; set; }

    public Guid? TopicId { get; set; }

    public string SessionType { get; set; } = null!;

    public DateTime StartedAt { get; set; }

    public DateTime? EndedAt { get; set; }

    public int TotalWords { get; set; }

    public int RememberedCount { get; set; }

    public int NotRememberedCount { get; set; }

    public string? SourceName { get; set; }

    public string SourceType { get; set; } = null!;

    public virtual ICollection<StudySessionDetail> StudySessionDetails { get; set; } = new List<StudySessionDetail>();

    public virtual VocabularyTopic? Topic { get; set; }

    public virtual User User { get; set; } = null!;
}
