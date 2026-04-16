namespace E_Learning.Domain.Quiz.Dtos.QuizAttempt
{
    public class QuizQuestionResponse
    {
        public Guid QuestionId { get; set; }
        public string QuestionText { get; set; } = null!;
        public int DisplayOrder { get; set; }
        public Guid? WordId { get; set; }
        public Guid? SelectedOptionId { get; set; }
        public List<QuizQuestionOptionResponse> Options { get; set; } = new();
    }
}
