namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class SaveQuizAnswerResponse
    {
        public Guid AttemptId { get; set; }
        public Guid QuestionId { get; set; }
        public Guid SelectedOptionId { get; set; }
        public bool IsCorrect { get; set; }
        public DateTime AnsweredAt { get; set; }
    }
}
