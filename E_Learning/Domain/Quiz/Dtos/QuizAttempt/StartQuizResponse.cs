namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class StartQuizResponse
    {
        public Guid AttemptId { get; set; }
        public Guid QuizId { get; set; }
        public string QuizTitle { get; set; } = null!;
        public DateTime StartedAt { get; set; }
        public int TotalQuestions { get; set; }
        public int? TimeLimitMinutes { get; set; }
    }
}
