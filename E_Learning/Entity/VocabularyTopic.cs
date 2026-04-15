using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class VocabularyTopic
{
    public Guid TopicId { get; set; }

    public string TopicName { get; set; } = null!;

    public string? Description { get; set; }

    public string? ImageUrl { get; set; }

    public int DisplayOrder { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<Quiz> Quizzes { get; set; } = new List<Quiz>();

    public virtual ICollection<StudySession> StudySessions { get; set; } = new List<StudySession>();

    public virtual ICollection<VocabularyWord> VocabularyWords { get; set; } = new List<VocabularyWord>();
}
