import DamagochiCore

/// Compatibility surface for the renderer. The implementation lives in
/// SpeciesAnatomySprites, where every catalog pet has a species-first 48×48
/// build rather than a shared mascot body.
enum ExpandedSpeciesSprites {
    static let speciesIDs = SpeciesAnatomySprites.speciesIDs

    static func frames(species: String, stage: Stage, direction: SpriteDirection) -> [PixelSprite]? {
        SpeciesAnatomySprites.frames(species: species, stage: stage, direction: direction)
    }
}
