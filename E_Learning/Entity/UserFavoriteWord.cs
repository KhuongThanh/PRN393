using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class UserFavoriteWord
{
    public Guid UserId { get; set; }

    public Guid WordId { get; set; }

    public DateTime AddedAt { get; set; }

    public virtual User User { get; set; } = null!;

    public virtual VocabularyWord Word { get; set; } = null!;
}
