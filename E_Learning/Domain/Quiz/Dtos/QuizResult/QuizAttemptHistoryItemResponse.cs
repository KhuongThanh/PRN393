namespace E_Learning.Domain.Quiz.Dtos.QuizResult
{
    public class QuizAttemptHistoryItemResponse
    {
        public Guid AttemptId { get; set; }
        public Guid QuizId { get; set; }
        public string QuizTitle { get; set; } = null!;
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = null!;
        public DateTime StartedAt { get; set; }
        public DateTime? SubmittedAt { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public decimal? Score { get; set; }
    }
}
