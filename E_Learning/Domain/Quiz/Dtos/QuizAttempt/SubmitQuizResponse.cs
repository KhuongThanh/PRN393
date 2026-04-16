namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class SubmitQuizResponse
    {
        public Guid AttemptId { get; set; }
        public Guid QuizId { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime SubmittedAt { get; set; }
        public int TotalQuestions { get; set; }
        public int CorrectAnswers { get; set; }
        public double Score { get; set; }
    }
}
