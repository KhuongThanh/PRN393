using System;
using System.Collections.Generic;

namespace E_Learning.Entity;

public partial class User
{
    public Guid UserId { get; set; }

    public string UserName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ICollection<QuizAttempt> QuizAttempts { get; set; } = new List<QuizAttempt>();

    public virtual ICollection<StudySession> StudySessions { get; set; } = new List<StudySession>();

    public virtual ICollection<UserFavoriteWord> UserFavoriteWords { get; set; } = new List<UserFavoriteWord>();

    public virtual UserProfile? UserProfile { get; set; }

    public virtual ICollection<UserWordProgress> UserWordProgresses { get; set; } = new List<UserWordProgress>();

    public virtual ICollection<Role> Roles { get; set; } = new List<Role>();
}
