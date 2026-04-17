namespace E_Learning.Domain.Admin.Quizzes.Dtos
{
    public class AdminQuizDetailDto
    {
        public Guid QuizId { get; set; }
        public Guid TopicId { get; set; }
        public string QuizTitle { get; set; } = null!;
        public string? Description { get; set; }
        public int? TimeLimitMinutes { get; set; }
        public bool IsActive { get; set; }
    }
}
