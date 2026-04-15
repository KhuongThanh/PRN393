using E_Learning.Domain.Vocabulary.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Vocabulary.Controllers
{
    [ApiController]
    [Route("api")]
    public class VocabularyWordsController : ControllerBase
    {
        private readonly IVocabularyWordService _wordService;

        public VocabularyWordsController(IVocabularyWordService wordService)
        {
            _wordService = wordService;
        }

        [HttpGet("vocabulary-topics/{topicId:guid}/words")]
        public async Task<IActionResult> GetWordsByTopic(
            Guid topicId,
            [FromQuery] string? keyword,
            [FromQuery] string? difficulty)
        {
            var result = await _wordService.GetWordsByTopicAsync(topicId, keyword, difficulty);
            return Ok(result);
        }

        [HttpGet("vocabulary-words/{wordId:guid}")]
        public async Task<IActionResult> GetWordDetail(Guid wordId)
        {
            var result = await _wordService.GetWordDetailAsync(wordId);
            return Ok(result);
        }
    }
}
