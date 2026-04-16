namespace E_Learning.Domain.Favorite.Dtos
{
    public class FavoriteWordDto
    {
        public Guid WordId { get; set; }
        public string WordText { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string? PartOfSpeech { get; set; }
        public string? Phonetic { get; set; }
        public string? ImageUrl { get; set; }
        public Guid? TopicId { get; set; }
        public string? TopicName { get; set; }
        public bool IsFavorite { get; set; } = true;
    }
}
