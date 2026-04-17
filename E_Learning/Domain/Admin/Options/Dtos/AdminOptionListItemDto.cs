namespace E_Learning.Domain.Admin.Options.Dtos
{
    public class AdminOptionListItemDto
    {
        public Guid OptionId { get; set; }
        public Guid QuestionId { get; set; }
        public string OptionText { get; set; } = null!;
        public bool IsCorrect { get; set; }
        public int DisplayOrder { get; set; }
    }
}
