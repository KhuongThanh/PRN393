namespace E_Learning.Domain.Admin.Questions.Dtos
{
    public class AdminQuestionDetailDto
    {
        public Guid QuestionId { get; set; }
        public Guid QuizId { get; set; }
        public Guid? WordId { get; set; }
        public string QuestionText { get; set; } = null!;
        public string? Explanation { get; set; }
        public int DisplayOrder { get; set; }
    }
}
