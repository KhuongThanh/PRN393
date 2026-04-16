namespace E_Learning.Domain.Quiz.Dtos.QuizResult
{
    public class QuizQuestionOptionResultResponse
    {
        public Guid OptionId { get; set; }
        public string OptionText { get; set; } = null!;
        public bool IsCorrect { get; set; }
        public int DisplayOrder { get; set; }
    }
}
