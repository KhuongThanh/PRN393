using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class UserProfile
{
    public Guid ProfileId { get; set; }

    public Guid UserId { get; set; }

    public string? FullName { get; set; }

    public string? AvatarUrl { get; set; }

    public int TargetDailyWords { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual User User { get; set; } = null!;
}
