namespace E_Learning.Domain.Dashboard.Dtos
{
    public class LatestQuizResultDto
    {
        public Guid AttemptId { get; set; }
        public Guid QuizId { get; set; }
        public string QuizTitle { get; set; } = null!;
        public DateTime? SubmittedAt { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public decimal? Score { get; set; }
    }
}
