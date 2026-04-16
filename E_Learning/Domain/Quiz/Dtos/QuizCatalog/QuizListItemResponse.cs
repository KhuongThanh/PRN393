namespace E_Learning.Domain.Quiz.Dtos.QuizCatalog
{
    public class QuizListItemResponse
    {
        public Guid QuizId { get; set; }
        public Guid TopicId { get; set; }
        public string QuizTitle { get; set; } = null!;
        public string? Description { get; set; }
        public int? TimeLimitMinutes { get; set; }
        public bool IsActive { get; set; }
        public int TotalQuestions { get; set; }
    }
}
