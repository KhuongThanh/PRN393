namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class SaveQuizAnswerRequest
    {
        public Guid QuestionId { get; set; }
        public Guid SelectedOptionId { get; set; }
    }
}
