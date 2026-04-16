namespace E_Learning.Domain.Quiz.Dtos.QuizResult
{
    public class QuizResultQuestionResponse
    {
        public Guid QuestionId { get; set; }
        public string QuestionText { get; set; } = null!;
        public Guid? WordId { get; set; }

        public Guid? SelectedOptionId { get; set; }
        public Guid? CorrectOptionId { get; set; }

        public bool IsCorrect { get; set; }
        public string? Explanation { get; set; }

        public List<QuizQuestionOptionResultResponse> Options { get; set; } = new();
    }
}
