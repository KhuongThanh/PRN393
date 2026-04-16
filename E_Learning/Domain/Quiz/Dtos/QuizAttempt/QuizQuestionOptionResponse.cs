namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class QuizQuestionOptionResponse
    {
        public Guid OptionId { get; set; }
        public string OptionText { get; set; } = null!;
        public int DisplayOrder { get; set; }
    }
}
